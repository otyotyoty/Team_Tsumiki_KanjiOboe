<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.AccountDTO" %>
<%@ page import="model.KanjiLogDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Calendar" %>
<%
    // ========== 로그인 체크 ==========
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int accID = user.getAccID();
    
    // ========== 오늘 날짜 정보 ==========
    Calendar cal = Calendar.getInstance();
    int todayYear = cal.get(Calendar.YEAR);
    int todayMonth = cal.get(Calendar.MONTH) + 1;
    int todayDay = cal.get(Calendar.DAY_OF_MONTH);
    
    // ========== 이번 달 정보 ==========
    cal.set(Calendar.DAY_OF_MONTH, 1);
    int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
    int lastDay = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
    
    // ========== 가입일 파싱 ==========
    int regDay = 0;
    String regDateStr = user.getRegDate();
    if (regDateStr != null && !regDateStr.isEmpty()) {
        String datePart = regDateStr.split(" ")[0];
        String[] parts = datePart.split("-");
        if (parts.length >= 3) {
            int regYear = Integer.parseInt(parts[0]);
            int regMonth = Integer.parseInt(parts[1]);
            int regDayParsed = Integer.parseInt(parts[2]);
            if (regYear == todayYear && regMonth == todayMonth) {
                regDay = regDayParsed;
            }
        }
    }
    
    // ========== 출석 날짜 가져오기 ==========
    KanjiLogDAO logDAO = new KanjiLogDAO();
    List<Integer> attendedDays = logDAO.getMonthAttendance(accID, todayYear, todayMonth);
    
    // ========== 오답 통계 ==========
    String[] menuLevels = {"N5", "N4", "N3", "N2", "N1"};
    int totalWrongAll = 0;
    int[] wrongPerLevel = new int[5];
    for (int i = 0; i < 5; i++) {
        wrongPerLevel[i] = logDAO.getWrongKanjiCountByLevel(accID, menuLevels[i]);
        totalWrongAll += wrongPerLevel[i];
    }
    
    // ========== 학습한 전체 한자 수 ==========
    List<Integer> studiedKanjiIDs = logDAO.getStudiedKanjiIDs(accID);
    int totalStudied = studiedKanjiIDs.size();
    
    // ========== 랜덤 격려 문구 ==========
    String[] motivationalQuotes = {
        "오늘의 작은 공부가 내일을 만들어요",
        "조금씩이라도, 계속하면 앞으로 나아갈 수 있어요",
        "오늘 한 만큼, 미래가 달라져",
        "지금의 노력은 분명 헛되지 않아요",
        "오늘을 소중히 할 수 있는 사람이 내일을 바꿔요"
    };
    int randomIndex = (int)(Math.random() * motivationalQuotes.length);
    String todayQuote = motivationalQuotes[randomIndex];
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>메인보드</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        /* ===== 닉네임 프로필 링크 ===== */
        .header h1 a {
            color: inherit;
            text-decoration: none;
            transition: opacity 0.3s;
        }
        .header h1 a:hover {
            opacity: 0.7;
        }
        
        /* ===== 헤더 레이아웃 ===== */
        .header {
            position: relative;
        }
        
        /* ===== 프로필 아이콘 (우측 상단) ===== */
        .profile-icon {
            position: absolute;
            top: 0;
            right: 0;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #fff;
            color: #a07cff;
            font-size: 22px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            border: 2.35px solid #a07cff; 
        }
        
        /* ===== 메뉴 섹션 ===== */
        .menu-section {
            display: flex;
            gap: 15px;
            margin: 20px 0;
        }
        .menu-card {
            flex: 1;
            position: relative;
            display: block;
            padding: 25px 20px;
            border-radius: 15px;
            text-decoration: none;
            color: white;
            text-align: center;
            cursor: pointer;
        }
        .menu-card.note {
            background: #FFF;
        }
        .menu-card.review {
   			background: #FFF;
}
        .menu-card h3 {
            font-size: 18px;
            margin-bottom: 8px;
        }
        .menu-card p {
            font-size: 13px;
            opacity: 0.9;
        }
        .menu-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(255,255,255,0.3);
            color: white;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        /* ===== 모달 ===== */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        .modal-box {
            background: white;
            padding: 40px;
            border-radius: 20px;
            max-width: 500px;
            width: 90%;
            text-align: center;
        }
        .modal-box h2 {
            margin-bottom: 25px;
            color: #333;
        }
        .modal-levels {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(80px, 1fr));
            gap: 15px;
            margin-bottom: 25px;
        }
        .modal-level-btn {
            display: block;
            padding: 18px 10px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            transition: transform 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .modal-level-btn:hover {
            transform: scale(1.08);
        }
        .modal-level-btn .lv-name {
            font-size: 22px;
            font-weight: bold;
            display: block;
        }
        .modal-level-btn .lv-cnt {
            font-size: 12px;
            margin-top: 4px;
            display: block;
            opacity: 0.8;
        }
        .modal-level-disabled {
            display: block;
            padding: 18px 10px;
            background: #ddd;
            color: #999;
            border-radius: 12px;
            opacity: 0.5;
        }
        .modal-level-disabled .lv-name {
            font-size: 22px;
            font-weight: bold;
            display: block;
        }
        .modal-level-disabled .lv-cnt {
            font-size: 12px;
            margin-top: 4px;
            display: block;
        }
        .modal-close {
            padding: 12px 30px;
            background: #666;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
        }
        .modal-close:hover {
            background: #555;
        }
        
        /* ===== 오답 없을 때 ===== */
        .no-wrong {
            text-align: center;
            padding: 30px;
            color: #999;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- ========== 헤더 (닉네임 클릭 → 프로필) ========== -->
        <div class="header">
            <h1><a href="profile.jsp"><%= user.getNickname() %>님</a></h1>
            <p><%= todayQuote %></p>
            <!-- 프로필 아이콘 -->
            <a href="profile.jsp" class="profile-icon" title="내 프로필">
                <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </a>
        </div>
        
        <!-- ========== 상단: 한자 공부 + 출석 캘린더 ========== -->
        <div class="top-section">
            <!-- 왼쪽: 한자 공부 -->
            <div class="level-section">
                <h2>한자 공부</h2>
                <p class="sub-text">단계별로 탄탄하게!</p>
                <div class="level-buttons">
                    <button class="level-btn" onclick="location.href='sectorSelect.jsp?level=N5'">N5</button>
                    <button class="level-btn" onclick="location.href='sectorSelect.jsp?level=N4'">N4</button>
                    <button class="level-btn" onclick="location.href='sectorSelect.jsp?level=N3'">N3</button>
                    <button class="level-btn" onclick="location.href='sectorSelect.jsp?level=N2'">N2</button>
                    <button class="level-btn" onclick="location.href='sectorSelect.jsp?level=N1'">N1</button>
                </div>
            </div>
            
            <!-- 오른쪽: 출석 캘린더 -->
            <div class="calendar-section" onclick="location.href='profile.jsp'" style="cursor:pointer;" title="클릭하면 학습 현황을 확인할 수 있어요!">
                <h3><%= todayMonth %>月</h3>
                
                <table class="calendar-table">
                    <thead>
                        <tr>
                            <th>日</th><th>月</th><th>火</th><th>水</th><th>木</th><th>金</th><th>土</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        int dayCount = 1;
                        int totalWeeks = (int) Math.ceil((firstDayOfWeek - 1 + lastDay) / 7.0);
                        
                        for (int week = 0; week < totalWeeks; week++) {
                    %>
                        <tr>
                        <%
                            for (int dow = 1; dow <= 7; dow++) {
                                if ((week == 0 && dow < firstDayOfWeek) || dayCount > lastDay) {
                        %>
                                    <td class="empty"></td>
                        <%
                                } else {
                                    String dayClass = "";
                                    if (regDay > 0 && dayCount < regDay) {
                                        dayClass = "gray";
                                    } else if (dayCount < todayDay) {
                                        dayClass = attendedDays.contains(dayCount) ? "green" : "red";
                                    } else if (dayCount == todayDay) {
                                        dayClass = attendedDays.contains(dayCount) ? "green" : "gray";
                                    } else {
                                        dayClass = "gray";
                                    }
                        %>
                                    <td class="day <%= dayClass %>"><%= dayCount %></td>
                        <%
                                    dayCount++;
                                }
                            }
                        %>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- ========== 오답노트 & 복습테스트 메뉴 ========== -->
        <div class="menu-section">
            <a href="javascript:void(0);" class="menu-card note" onclick="showLevelModal()">
                <div class="menu-title">
                <h2>📝</h2>
                <h3>오답노트</h3>
                </div>
                <p>틀린 문제를 한 눈에!</p>
                <% if (totalWrongAll > 0) { %>
                    <span class="menu-badge"><%= totalWrongAll %>개</span>
                <% } %>
            </a>
            
            <a href="WrongKanjiTest.jsp" class="menu-card review">
                <div class="menu-title">
                <h2>🎯</h2>
                <h3> 복습 테스트</h3>
                </div>
                <p>오답 중심으로 복습 가능!</p>
                <% if (totalStudied > 0) { %>
                    <span class="menu-badge"><%= totalStudied %>개</span>
                <% } %>
            </a>
        </div>
        
        <!-- ========== 레벨 선택 모달 (오답노트용만) ========== -->
        <div id="levelModal" class="modal-overlay">
            <div class="modal-box">
                <h2>오답노트 - 레벨 선택</h2>
                
                <% if (totalWrongAll == 0) { %>
                    <div class="no-wrong">
                        😊 틀린 문제가 없습니다!<br>
                        테스트를 먼저 진행해보세요.
                    </div>
                <% } else { %>
                    <div class="modal-levels">
                        <% for (int i = 0; i < 5; i++) {
                            if (wrongPerLevel[i] > 0) { %>
                                <a href="WrongKanjiStudy.jsp?level=<%= menuLevels[i] %>" class="modal-level-btn">
                                    <span class="lv-name"><%= menuLevels[i] %></span>
                                    <span class="lv-cnt"><%= wrongPerLevel[i] %>개</span>
                                </a>
                        <%  } else { %>
                                <div class="modal-level-disabled">
                                    <span class="lv-name"><%= menuLevels[i] %></span>
                                    <span class="lv-cnt">0개</span>
                                </div>
                        <%  }
                        } %>
                    </div>
                <% } %>
                
                <button onclick="closeModal()" class="modal-close">닫기</button>
            </div>
        </div>
        
        <!-- ========== 로그아웃 ========== -->
        <button class="logout-btn" onclick="location.href='LogoutCon.do'">로그아웃</button>
    </div>
    
    <script>
    function showLevelModal() {
        document.getElementById('levelModal').style.display = 'flex';
    }
    
    function closeModal() {
        document.getElementById('levelModal').style.display = 'none';
    }
    
    document.getElementById('levelModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
    </script>
</body>
</html>