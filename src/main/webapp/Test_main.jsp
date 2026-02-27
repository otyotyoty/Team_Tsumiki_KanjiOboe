<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.KanjiDAO" %>
<%@ page import="model.KanjiDTO" %>
<%@ page import="model.AccountDTO" %>
<%
    // ========== 로그인 체크 ==========
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // ========== 파라미터 받기 ==========
    String level = request.getParameter("level");
    String sectorParam = request.getParameter("sector");
    int sector = 1;
    
    if (sectorParam != null && !sectorParam.isEmpty()) {
        try {
            sector = Integer.parseInt(sectorParam);
        } catch (NumberFormatException e) {
            sector = 1;
        }
    }
    
    // ========== DB에서 해당 섹터의 한자 가져오기 ==========
    KanjiDAO kanjiDAO = new KanjiDAO();
    List<KanjiDTO> kanjiList = kanjiDAO.getKanjiByLevelSector(level, sector);
    
    if (kanjiList == null || kanjiList.isEmpty()) {
        out.println("<script>alert('테스트 데이터가 없습니다.'); history.back();</script>");
        return;
    }
    
    // ★★★ 랜덤 셔플 + 최대 10문제 ★★★
    Collections.shuffle(kanjiList);
    int maxQuestions = 10;
    if (kanjiList.size() > maxQuestions) {
        kanjiList = new ArrayList<>(kanjiList.subList(0, maxQuestions));
    }
    
    // ========== 퀴즈 데이터 준비 ==========
    // 모든 읽기(음독/훈독) 수집 (오답 보기용)
    // ★ 같은 레벨 전체에서 오답 보기를 가져와서 다양하게
    List<KanjiDTO> allLevelKanji = kanjiDAO.findByLevel(level);
    List<String> allReadings = new ArrayList<>();
    for (KanjiDTO k : allLevelKanji) {
        if (k.getOnyomi1() != null && !k.getOnyomi1().isEmpty()) allReadings.add(k.getOnyomi1());
        if (k.getOnyomi2() != null && !k.getOnyomi2().isEmpty()) allReadings.add(k.getOnyomi2());
        if (k.getKunyomi1() != null && !k.getKunyomi1().isEmpty()) allReadings.add(k.getKunyomi1());
    }
    
    // 퀴즈용 배열로 처리
    List<String> quizKanjiList = new ArrayList<>();
    List<String> quizCorrectList = new ArrayList<>();
    List<List<String>> quizOptionsList = new ArrayList<>();
    List<Integer> quizCorrectIndexList = new ArrayList<>();
    
    Random rand = new Random();
    
    for (int i = 0; i < kanjiList.size(); i++) {
        KanjiDTO kanji = kanjiList.get(i);
        String questionKanji = kanji.getKanji();
        
        // 정답: 첫번째 음독 (없으면 훈독)
        String correctAnswer = kanji.getOnyomi1();
        if (correctAnswer == null || correctAnswer.isEmpty()) {
            correctAnswer = kanji.getKunyomi1();
        }
        if (correctAnswer == null || correctAnswer.isEmpty()) {
            continue; // 읽기 정보 없으면 스킵
        }
        
        // 오답 보기 수집
        List<String> wrongOptions = new ArrayList<>();
        for (String reading : allReadings) {
            if (!reading.equals(correctAnswer) && !wrongOptions.contains(reading)) {
                wrongOptions.add(reading);
            }
        }
        Collections.shuffle(wrongOptions);
        
        // 보기 구성: 정답 + 오답 3개
        List<String> options = new ArrayList<>();
        options.add(correctAnswer);
        for (int j = 0; j < 3 && j < wrongOptions.size(); j++) {
            options.add(wrongOptions.get(j));
        }
        Collections.shuffle(options);
        
        int correctIndex = options.indexOf(correctAnswer);
        
        quizKanjiList.add(questionKanji);
        quizCorrectList.add(correctAnswer);
        quizOptionsList.add(options);
        quizCorrectIndexList.add(correctIndex);
    }
    
    int quizSize = quizKanjiList.size();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>한자 테스트 - <%= level %> 섹터 <%= sector %></title>
    <link rel="stylesheet" href="css/study.css">
</head>
<body>
    <div class="quiz-container">
        <div class="quiz-header">
            <div class="level-badge"><%= level %> - 섹터 <%= sector %></div>
            <div class="progress-info">
                <span><span id="currentQ">1</span>/<span id="totalQ"><%= quizSize %></span></span>
                <span class="timer" id="timer">5</span>
            </div>
        </div>
        <div class="question-section">
            <div class="question-kanji" id="questionKanji"></div>
        </div>
        <div class="options-grid" id="optionsContainer"></div>
        <button class="pass-button" id="passButton">모르겠어요</button>
    </div>
    
    <script>
        var quizData = [];
        var testLevel = "<%= level %>";
        var testSector = <%= sector %>;
        
        <%-- 퀴즈 데이터를 JavaScript 배열로 전달 --%>
        <% for (int i = 0; i < quizSize; i++) {
            String kEsc = quizKanjiList.get(i).replace("\\", "\\\\").replace("\"", "\\\"");
            List<String> opts = quizOptionsList.get(i);
        %>
        quizData.push({
            question: "<%= kEsc %>",
            options: [<% for (int j = 0; j < opts.size(); j++) {
                String oEsc = opts.get(j).replace("\\", "\\\\").replace("\"", "\\\"");
            %>"<%= oEsc %>"<%= j < opts.size()-1 ? "," : "" %><% } %>],
            correctIndex: <%= quizCorrectIndexList.get(i) %>
        });
        <% } %>
        
        var currentQ = 0;
        var score = 0;
        var isAnswered = false;
        var timerInterval;
        var resultData = [];
        
        function init() {
            if (quizData.length === 0) {
                alert("퀴즈 데이터가 없습니다.");
                location.href = "main.jsp";
                return;
            }
            loadQuestion();
        }
        
        function loadQuestion() {
            isAnswered = false;
            var q = quizData[currentQ];
            document.getElementById("currentQ").textContent = currentQ + 1;
            document.getElementById("questionKanji").textContent = q.question;
            
            var container = document.getElementById("optionsContainer");
            container.innerHTML = "";
            
            for (var i = 0; i < q.options.length; i++) {
                var btn = document.createElement("button");
                btn.className = "option-btn";
                btn.textContent = q.options[i];
                btn.setAttribute("data-index", i);
                btn.onclick = (function(idx) {
                    return function() { selectOption(idx); };
                })(i);
                container.appendChild(btn);
            }
            
            document.getElementById("passButton").disabled = false;
            startTimer();
        }
        
        function startTimer() {
            var timeLeft = 5;
            document.getElementById("timer").textContent = timeLeft;
            if (timerInterval) clearInterval(timerInterval);
            timerInterval = setInterval(function() {
                timeLeft--;
                document.getElementById("timer").textContent = timeLeft;
                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    handleTimeout();
                }
            }, 1000);
        }
        
        function selectOption(selIdx) {
            if (isAnswered) return;
            isAnswered = true;
            clearInterval(timerInterval);
            
            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;
            
            var correct = (selIdx === q.correctIndex);
            resultData.push({ kanji: q.question, isCorrect: correct ? 1 : 0 });
            
            if (correct) { btns[selIdx].classList.add("correct"); score++; }
            else { btns[selIdx].classList.add("wrong"); btns[q.correctIndex].classList.add("answer"); }
            
            setTimeout(nextQuestion, 1500);
        }
        
        function passQuestion() {
            if (isAnswered) return;
            isAnswered = true;
            clearInterval(timerInterval);
            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;
            resultData.push({ kanji: q.question, isCorrect: 0 });
            btns[q.correctIndex].classList.add("answer");
            setTimeout(nextQuestion, 1500);
        }
        
        function handleTimeout() {
            if (isAnswered) return;
            isAnswered = true;
            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;
            resultData.push({ kanji: q.question, isCorrect: 0 });
            btns[q.correctIndex].classList.add("answer");
            setTimeout(nextQuestion, 1500);
        }
        
        function nextQuestion() {
            currentQ++;
            if (currentQ >= quizData.length) { endQuiz(); return; }
            loadQuestion();
        }
        
        function endQuiz() {
            if (timerInterval) clearInterval(timerInterval);
            var form = document.createElement("form");
            form.method = "POST";
            form.action = "Test_result.jsp";
            addInput(form, "level", testLevel);
            addInput(form, "sector", testSector);
            addInput(form, "score", score);
            addInput(form, "total", quizData.length);
            addInput(form, "resultData", JSON.stringify(resultData));
            document.body.appendChild(form);
            form.submit();
        }
        
        function addInput(form, name, value) {
            var inp = document.createElement("input");
            inp.type = "hidden"; inp.name = name; inp.value = value;
            form.appendChild(inp);
        }
        
        document.getElementById("passButton").onclick = passQuestion;
        window.onload = init;
    </script>
</body>
</html>