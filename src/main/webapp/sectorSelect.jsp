<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.AccountDTO, model.KanjiDAO" %>
<%
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String level = request.getParameter("level"); 
    KanjiDAO kanjiDAO = new KanjiDAO();

    int totalKanji = kanjiDAO.countByLevel(level);
    int maxSector = kanjiDAO.getMaxSector(level);

    int displaySectors = 30; // 30개 섹터 표시
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= level %> 섹터 선택</title>
    <link rel="stylesheet" href="css/sectorSelect.css">
</head>
<body>
    <div class="container">
        <header class="header">
            <h1><%= level %></h1>
            <p>오늘의 작은 공부가 내일을 만들어요</p>
            <div class="kanji-count">등록된 한자: <strong><%= totalKanji %></strong>개</div>
        </header>

        <section class="sector-grid">
            <%
                for (int i = 1; i <= displaySectors; i++) {
                    // 실제 데이터가 있는 섹터인지 확인
                    boolean hasKanji = (i <= maxSector) && (kanjiDAO.countBySector(level, i) > 0);
                    String sectorText = String.format("%02d", i);

                    if (hasKanji) {
            %>
                        <a href="kanjiStudy.jsp?level=<%= level %>&sector=<%= i %>" 
                           class="sector-btn active">
                            <%= sectorText %>
                        </a>
            <%
                    } else {
            %>
                        <span class="sector-btn inactive">
                            <%= sectorText %>
                        </span>
            <%
                    }
                }
            %>
        </section>

        <footer>
            <button class="back-btn" onclick="location.href='main.jsp'">돌아가기</button>
        </footer>
    </div>
</body>
</html>