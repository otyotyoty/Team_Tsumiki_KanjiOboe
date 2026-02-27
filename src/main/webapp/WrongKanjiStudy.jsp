<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="model.*"%>
<%@ page import="java.util.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>틀린 단어 복습</title>
<link rel="stylesheet" href="css/main.css">
<style>
body {
	font-family: Arial, sans-serif;
	background-color: #f5f5f5;
	margin: 0;
	padding: 20px;
}

.container {
	max-width: 900px;
	margin: 0 auto;
	background: white;
	padding: 30px;
	border-radius: 10px;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

h1 {
	text-align: center;
	color: #333;
	margin-bottom: 10px;
}

.info {
	text-align: center;
	color: #666;
	margin-bottom: 30px;
	font-size: 14px;
}

.wrong-count {
	background: #ff6b6b;
	color: white;
	padding: 10px 20px;
	border-radius: 20px;
	display: inline-block;
	margin-bottom: 20px;
}

.kanji-card {
	border: 2px solid #ddd;
	padding: 30px;
	margin-bottom: 20px;
	border-radius: 8px;
	background: #fafafa;
}

.kanji-char {
	font-size: 80px;
	text-align: center;
	color: #333;
	margin: 20px 0;
}

.kanji-info {
	margin: 15px 0;
}

.kanji-info h3 {
	color: #555;
	margin-bottom: 10px;
	font-size: 16px;
	border-bottom: 2px solid #4CAF50;
	padding-bottom: 5px;
}

.kanji-info p {
	color: #666;
	font-size: 15px;
	line-height: 1.6;
	margin: 5px 0;
}

.score-badge {
	display: inline-block;
	padding: 5px 15px;
	border-radius: 15px;
	font-size: 13px;
	margin-right: 10px;
}

.correct-badge {
	background: #4CAF50;
	color: white;
}

.wrong-badge {
	background: #ff6b6b;
	color: white;
}

.btn-container {
	text-align: center;
	margin-top: 30px;
}

.btn {
	padding: 12px 30px;
	margin: 0 10px;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	font-size: 16px;
	text-decoration: none;
	display: inline-block;
}

.btn-primary {
	background: #4CAF50;
	color: white;
}

.btn-primary:hover {
	background: #45a049;
}

.btn-secondary {
	background: #666;
	color: white;
}

.btn-secondary:hover {
	background: #555;
}

.no-data {
	text-align: center;
	padding: 50px;
	color: #999;
	font-size: 18px;
}
</style>
</head>
<body>
	<%
	// 세션 체크
	AccountDTO loginUser = (AccountDTO) session.getAttribute("loginUser");
	if (loginUser == null) {
		response.sendRedirect("login.jsp");
		return;
	}

	// 파라미터 받기
	String level = request.getParameter("level");
	String sectorStr = request.getParameter("sector");

	if (level == null) {
		out.println("<div class='container'><div class='no-data'>레벨 정보가 없습니다.</div></div>");
		return;
	}

	int accID = loginUser.getAccID();
	KanjiLogDAO logDao = new KanjiLogDAO();
	KanjiDAO kanjiDao = new KanjiDAO();

	// 틀린 단어 ID 목록 가져오기
	List<Integer> wrongKanjiIDs;
	int totalWrong;

	if (sectorStr != null && !sectorStr.isEmpty()) {
		// 섹터별 조회
		int sector = Integer.parseInt(sectorStr);
		wrongKanjiIDs = logDao.getWrongKanjiIDsByLevelSector(accID, level, sector);
		totalWrong = logDao.getWrongKanjiCountByLevelSector(accID, level, sector);
	} else {
		// 레벨별 전체 조회
		wrongKanjiIDs = logDao.getWrongKanjiIDsByLevel(accID, level);
		totalWrong = logDao.getWrongKanjiCountByLevel(accID, level);
	}
	%>

	<div class="container">
		<h1>🔄 틀린 단어 복습</h1>
		<div class="info">
			<%=level%><%=(sectorStr != null ? " - 섹터 " + sectorStr : "")%>
			<br> <span class="wrong-count">틀린 단어: <%=totalWrong%>개
			</span>
		</div>

		<%
		if (wrongKanjiIDs.isEmpty()) {
		%>
		<div class="no-data">
			😊 축하합니다!<br> 틀린 단어가 없습니다.
		</div>
		<%
		} else {
		// 틀린 한자들 표시
		for (Integer kanjiID : wrongKanjiIDs) {
			KanjiDTO kanji = kanjiDao.findByKanjiID(kanjiID);
			if (kanji == null)
				continue;

			// 정답/오답 횟수
			int[] score = logDao.getKanjiScore(accID, kanjiID);
			int correctCnt = score[0];
			int wrongCnt = score[1];
		%>
		<div class="kanji-card">
			<div class="kanji-char"><%=kanji.getKanji()%></div>

			<div class="kanji-info">
				<h3>📖 의미</h3>
				<p>
					<strong><%=kanji.getKoreanMeaning()%></strong>
				</p>
				<%
				if (kanji.getMeaningDescription() != null && !kanji.getMeaningDescription().isEmpty()) {
				%>
				<p><%=kanji.getMeaningDescription()%></p>
				<%
				}
				%>
			</div>

			<div class="kanji-info">
				<h3>🔊 읽기</h3>
				<%
				if (kanji.getOnyomi1() != null) {
				%>
				<p>
					<strong>음독:</strong>
					<%=kanji.getOnyomi1()%>
					<%=(kanji.getOnyomi2() != null ? ", " + kanji.getOnyomi2() : "")%>
					<%=(kanji.getOnyomi3() != null ? ", " + kanji.getOnyomi3() : "")%>
				</p>
				<%
				}
				%>
				<%
				if (kanji.getKunyomi1() != null) {
				%>
				<p>
					<strong>훈독:</strong>
					<%=kanji.getKunyomi1()%>
					<%=(kanji.getKunyomi2() != null ? ", " + kanji.getKunyomi2() : "")%>
					<%=(kanji.getKunyomi3() != null ? ", " + kanji.getKunyomi3() : "")%>
				</p>
				<%
				}
				%>
			</div>

			<div class="kanji-info">
				<h3>📝 예시</h3>
				<%
				if (kanji.getExample1() != null) {
				%>
				<p><%=kanji.getExample1()%></p>
				<%
				}
				%>
				<%
				if (kanji.getExample2() != null) {
				%>
				<p><%=kanji.getExample2()%></p>
				<%
				}
				%>
				<%
				if (kanji.getExample3() != null) {
				%>
				<p><%=kanji.getExample3()%></p>
				<%
				}
				%>
			</div>

			<div class="kanji-info">
				<h3>📊 학습 기록</h3>
				<span class="score-badge correct-badge">정답 <%=correctCnt%>회
				</span> <span class="score-badge wrong-badge">오답 <%=wrongCnt%>회
				</span>
			</div>
		</div>
		<%
		}
		%>

		<div class="btn-container">
			<a
				href="WrongKanjiTest.jsp?level=<%=level%>&mode=wrong<%=(sectorStr != null ? "&sector=" + sectorStr : "")%>"
				class="btn btn-primary"> 📝 오답 테스트 시작 </a> <a href="main.jsp"
				class="btn btn-secondary">메인으로</a>
		</div>
		<%
		}
		%>
	</div>

</body>
</html>