<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.AccountDTO, model.MypageDAO" %>
<%
    // ========== 로그인 체크 ==========
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int accID = user.getAccID();
    String nickname = user.getNickname();
    String email = user.getUserID();
    String initial = (nickname != null && !nickname.isEmpty()) ? nickname.substring(0, 1) : "?";

    // ========== 통계 데이터 조회 ==========
    MypageDAO dao = new MypageDAO();

    int totalStudied = dao.getTotalStudiedCount(accID);
    int totalKanji = dao.getTotalKanjiCount();
    int accuracyRate = dao.getAccuracyRate(accID);
    int consecutiveDays = dao.getConsecutiveDays(accID);

    double progressPercent = (totalKanji > 0) ? Math.round((double) totalStudied / totalKanji * 1000) / 10.0 : 0;

    // ========== 레벨별 데이터 ==========
    String[] levels = {"N5", "N4", "N3", "N2", "N1"};
    String[] levelNames = {"기초", "초급", "중급", "중상급", "고급"};
    String[] levelColors = {"#34d399", "#3b82f6", "#8b5cf6", "#f59e0b", "#ec4899"};
    int[] levelStudied = new int[5];
    int[] levelTotal = new int[5];
    for (int i = 0; i < 5; i++) {
        levelStudied[i] = dao.getLevelStudiedCount(accID, levels[i]);
        levelTotal[i] = dao.getLevelTotalCount(levels[i]);
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로필 - <%= nickname %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans KR', -apple-system, sans-serif;
            background: linear-gradient(135deg, #a07cff 0%, #c77dff 50%, #6fa8ff 100%);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: flex-start;
            padding: 40px 20px;
        }
        .container {
            background: linear-gradient(135deg, #f8fbff, #f3ecff);
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 600px; width: 100%;
        }

        /* ===== 프로필 헤더 ===== */
        .profile-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 35px;
        }
        .avatar {
            width: 70px; height: 70px;
            border-radius: 50%;
            background: linear-gradient(135deg, #a07cff, #c77dff);
            color: white;
            font-size: 28px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .profile-info h2 {
            font-size: 22px; color: #333;
            margin-bottom: 2px;
        }
        .profile-info p {
            font-size: 14px; color: #888;
        }

        /* ===== 전체 학습 현황 ===== */
        .section-title {
            font-size: 15px; font-weight: 600;
            color: #555; margin-bottom: 15px;
        }
        .total-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
        }
        .total-number {
            display: flex;
            align-items: baseline;
            gap: 6px;
            margin-bottom: 8px;
        }
        .total-number .big {
            font-size: 48px; font-weight: 700; color: #333;
        }
        .total-number .sub {
            font-size: 18px; color: #888;
        }
        .percent-text {
            font-size: 14px; color: #34d399;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .progress-bar-bg {
            width: 100%; height: 10px;
            background: #e5e7eb;
            border-radius: 5px;
            overflow: hidden;
        }
        .progress-bar-fill {
            height: 100%;
            border-radius: 5px;
            background: linear-gradient(90deg, #6fa8ff, #4f7cff);
            transition: width 0.8s ease;
        }

        /* ===== 3개 통계 카드 ===== */
        .stat-cards {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }
        .stat-card {
            flex: 1;
            border-radius: 16px;
            padding: 20px 15px;
            text-align: center;
        }
        .stat-card .stat-value {
            font-size: 28px; font-weight: 700;
            margin-bottom: 5px;
        }
        .stat-card .stat-label {
            font-size: 13px; font-weight: 500;
        }
        .stat-card.accuracy {
            background: #fef9c3;
        }
        .stat-card.accuracy .stat-value { color: #16a34a; }
        .stat-card.accuracy .stat-label { color: #65a30d; }

        .stat-card.streak {
            background: #dcfce7;
        }
        .stat-card.streak .stat-value { color: #2563eb; }
        .stat-card.streak .stat-label { color: #16a34a; }

        /* ===== 레벨별 진척도 ===== */
        .level-progress {
            margin-bottom: 25px;
        }
        .level-item {
            margin-bottom: 18px;
        }
        .level-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
        }
        .level-name {
            font-size: 15px; font-weight: 600; color: #333;
        }
        .level-count {
            font-size: 14px; color: #888;
        }
        .level-bar-bg {
            width: 100%; height: 8px;
            background: #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
        }
        .level-bar-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.8s ease;
        }

        /* ===== 돌아가기 버튼 ===== */
        .back-btn {
            display: block;
            width: 100%;
            padding: 15px;
            font-size: 15px; font-weight: 600;
            background: #e0e0e0;
            color: #555;
            border: none; border-radius: 20px;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s;
        }
        .back-btn:hover {
            background: #d0d0d0;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">

        <!-- ===== 프로필 헤더 ===== -->
        <div class="profile-header">
            <div class="avatar"><%= initial %></div>
            <div class="profile-info">
                <h2><%= nickname %></h2>
                <p><%= email %></p>
            </div>
        </div>

        <!-- ===== 전체 학습 현황 ===== -->
        <div class="section-title">전체 학습 현황 (총 <%= String.format("%,d", totalKanji) %>자)</div>
        <div class="total-card">
            <div class="total-number">
                <span class="big"><%= totalStudied %></span>
                <span class="sub">/ <%= String.format("%,d", totalKanji) %>자</span>
            </div>
            <div class="percent-text"><%= progressPercent %>% 완료</div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: <%= progressPercent %>%;"></div>
            </div>
        </div>

        <!-- ===== 3개 통계 카드 ===== -->
        <div class="stat-cards">
            <div class="stat-card accuracy">
                <div class="stat-value"><%= accuracyRate %>%</div>
                <div class="stat-label">정답률</div>
            </div>
            <div class="stat-card streak">
                <div class="stat-value"><%= consecutiveDays %>일</div>
                <div class="stat-label">연속 학습</div>
            </div>
        </div>

        <!-- ===== 레벨별 진척도 ===== -->
        <div class="section-title">레벨별 진척도</div>
        <div class="level-progress">
            <% for (int i = 0; i < 5; i++) {
                double lvlPercent = (levelTotal[i] > 0) ? (double) levelStudied[i] / levelTotal[i] * 100 : 0;
            %>
            <div class="level-item">
                <div class="level-item-header">
                    <span class="level-name"><%= levels[i] %> (<%= levelNames[i] %>)</span>
                    <span class="level-count"><%= levelStudied[i] %> / <%= levelTotal[i] %>자</span>
                </div>
                <div class="level-bar-bg">
                    <div class="level-bar-fill" style="width: <%= lvlPercent %>%; background: <%= levelColors[i] %>;"></div>
                </div>
            </div>
            <% } %>
        </div>

        <!-- ===== 돌아가기 ===== -->
        <button class="back-btn" onclick="location.href='main.jsp'">홈으로 돌아가기</button>
    </div>
</body>
</html>