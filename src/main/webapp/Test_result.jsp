<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.AccountDTO" %>
<%@ page import="model.KanjiDAO" %>
<%@ page import="model.KanjiLogDAO" %>
<%
    // ========== 로그인 체크 ==========
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int accID = user.getAccID(); // kanji_log FK용
    
    // ========== 파라미터 받기 ==========
    request.setCharacterEncoding("UTF-8");
    String level = request.getParameter("level");
    String sectorParam = request.getParameter("sector");
    String scoreParam = request.getParameter("score");
    String totalParam = request.getParameter("total");
    String resultDataParam = request.getParameter("resultData");
    
    int sector = 1;
    int score = 0;
    int total = 10;
    
    try {
        if (sectorParam != null) sector = Integer.parseInt(sectorParam);
        if (scoreParam != null) score = Integer.parseInt(scoreParam);
        if (totalParam != null) total = Integer.parseInt(totalParam);
    } catch (NumberFormatException e) {
        // 기본값 사용
    }
    
    // ========== 오늘 출석 여부 확인 (kanji_log 기반) ==========
    KanjiLogDAO logDAO = new KanjiLogDAO();
    boolean isFirstTodayStudy = !logDAO.isTodayAttended(accID);
    
    // ========== 테스트 결과를 kanji_log에 저장 ==========
    boolean saveSuccess = false;
    if (resultDataParam != null && !resultDataParam.isEmpty()) {
        try {
            KanjiDAO kanjiDAO = new KanjiDAO();
            
            // JSON 파싱: [{"kanji":"日","isCorrect":1}, ...]
            String data = resultDataParam.trim();
            if (data.startsWith("[")) data = data.substring(1);
            if (data.endsWith("]")) data = data.substring(0, data.length() - 1);
            
            if (!data.isEmpty()) {
                String[] items = data.split("\\},\\{");
                
                for (String item : items) {
                    item = item.replace("{", "").replace("}", "");
                    
                    String kanjiChar = null;
                    int isCorrect = 0;
                    
                    String[] fields = item.split(",");
                    for (String field : fields) {
                        field = field.trim();
                        if (field.startsWith("\"kanji\"")) {
                            int colonIdx = field.indexOf(":");
                            if (colonIdx > 0) {
                                kanjiChar = field.substring(colonIdx + 1).replace("\"", "").trim();
                            }
                        } else if (field.startsWith("\"isCorrect\"")) {
                            int colonIdx = field.indexOf(":");
                            if (colonIdx > 0) {
                                isCorrect = Integer.parseInt(field.substring(colonIdx + 1).trim());
                            }
                        }
                    }
                    
                    if (kanjiChar != null && !kanjiChar.isEmpty()) {
                        // 한자문자 + 레벨 + 섹터로 kanjiID 조회
                        int kanjiID = kanjiDAO.getKanjiID(kanjiChar, level, sector);
                        
                        if (kanjiID > 0) {
                            // ★ kanji_log에 INSERT (accID 기준)
                            logDAO.insertLog(accID, kanjiID, isCorrect);
                            saveSuccess = true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // ========== 결과 메시지 설정 ==========
    double percentage = (total > 0) ? ((double) score / total * 100) : 0;
    String message = "";
    String icon = "";
    
    if (percentage == 100) {
        message = "완벽합니다! 🌟<br>모든 문제를 맞히셨네요!";
        icon = "🏆";
    } else if (percentage >= 80) {
        message = "훌륭해요!<br>조금만 더 복습하면 완벽해요!";
        icon = "🎉";
    } else if (percentage >= 60) {
        message = "좋아요!<br>꾸준히 노력하고 있네요!";
        icon = "😊";
    } else if (percentage >= 40) {
        message = "괜찮아요!<br>복습이 좀 더 필요해요!";
        icon = "📚";
    } else {
        message = "힘내세요!<br>다시 학습하고 도전해보세요!";
        icon = "💪";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>퀴즈 결과</title>
    <link rel="stylesheet" href="css/study.css">
</head>
<body>
    <div class="result-container">
        <div class="result-icon"><%= icon %></div>
        <h1 class="result-title">퀴즈 완료!</h1>
        <p class="level-info"><%= level %> - 섹터 <%= sector %></p>
        
        <div class="score-display"><%= score %> / <%= total %></div>
        <div class="score-label">맞힌 문제 수</div>
        
        <% if (isFirstTodayStudy && saveSuccess) { %>
            <div class="attendance-badge new">✅ 오늘 출석 완료!</div>
        <% } else if (saveSuccess) { %>
            <div class="attendance-badge already">📌 오늘 이미 학습함</div>
        <% } else { %>
            <div class="attendance-badge fail">⚠️ 저장 실패</div>
        <% } %>
        
        <div class="result-message"><%= message %></div>
        
        <div class="button-group">
            <a href="Test_main.jsp?level=<%= level %>&sector=<%= sector %>" class="btn btn-primary">🔄 다시 도전하기</a>
            <a href="kanjiStudy.jsp?level=<%= level %>&sector=<%= sector %>" class="btn btn-secondary">📖 다시 학습하기</a>
            <a href="main.jsp" class="btn btn-secondary">🏠 홈으로</a>
        </div>
    </div>
</body>
</html>