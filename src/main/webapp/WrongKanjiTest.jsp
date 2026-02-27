<%@page import="model.KanjiLogDAO"%>
<%@page import="model.KanjiDAO"%>
<%@page import="model.KanjiDTO"%>
<%@page import="model.AccountDTO"%>
<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>복습 테스트</title>
    <link rel="stylesheet" href="css/study.css">
</head>
<body>
<%
    // 세션 체크
    AccountDTO loginUser = (AccountDTO) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int accID = loginUser.getAccID();

    // 파라미터 받기
    String level = request.getParameter("level");
    String sectorStr = request.getParameter("sector");

    // 학습한 모든 한자 가져오기 (정답 + 오답)
   int sector = 0;
    if (sectorStr != null && !sectorStr.isEmpty()) {
        sector = Integer.parseInt(sectorStr);
    }

    // ★ 오답 모드 체크
    String mode = request.getParameter("mode");
    boolean isWrongMode = "wrong".equals(mode);

    KanjiLogDAO logDao = new KanjiLogDAO();
    List<Integer> studiedKanjiIDs;

    if (isWrongMode && level != null && !level.isEmpty()) {
        // ★ 오답 모드: 해당 레벨의 오답 한자만 가져오기
        if (sector > 0) {
            studiedKanjiIDs = logDao.getWrongKanjiIDsByLevelSector(accID, level, sector);
        } else {
            studiedKanjiIDs = logDao.getWrongKanjiIDsByLevel(accID, level);
        }
        
        if (studiedKanjiIDs.isEmpty()) {
            out.println("<script>alert('틀린 한자가 없습니다! 축하합니다!'); location.href='main.jsp';</script>");
            return;
        }
    } else {
        // 기존 복습 모드: 학습한 모든 한자
        studiedKanjiIDs = logDao.getStudiedKanjiIDs(accID);

        if (studiedKanjiIDs.isEmpty()) {
            out.println("<script>alert('학습한 한자가 없습니다. 먼저 테스트를 진행해주세요.'); location.href='main.jsp';</script>");
            return;
        }
    }

    // 한자 목록 생성
    KanjiDAO kanjiDao = new KanjiDAO();
    List<KanjiDTO> studiedKanjiList = new ArrayList<>();
    for (int kanjiID : studiedKanjiIDs) {
        KanjiDTO kanji = kanjiDao.findByKanjiID(kanjiID);
        if (kanji != null) {
            studiedKanjiList.add(kanji);
        }
    }

    // ★★★ 랜덤 셔플 후 최대 10개만 추출 ★★★
    Collections.shuffle(studiedKanjiList);
    int maxQuestions = 10; // 한 번에 10문제씩
    if (studiedKanjiList.size() > maxQuestions) {
        studiedKanjiList = studiedKanjiList.subList(0, maxQuestions);
    }

    // 전체 한자 목록 (선택지 생성용)
    List<KanjiDTO> allKanjiList = new ArrayList<>();
    
    if (level != null && !level.isEmpty()) {
        if (sector > 0) {
            allKanjiList = kanjiDao.findBySector(level, sector);
        } else {
            allKanjiList = kanjiDao.findByLevel(level);
        }
    } else {
        Set<String> levels = new HashSet<>();
        for (KanjiDTO k : studiedKanjiList) {
            levels.add(k.getJlptLevel());
        }
        for (String lv : levels) {
            allKanjiList.addAll(kanjiDao.findByLevel(lv));
        }
    }
    
    // ★ 선택지 풀도 셔플해서 오답 보기가 매번 다르게
    Collections.shuffle(allKanjiList);

    // 각 문제에 대한 선택지 생성
    Random random = new Random();
    Map<Integer, List<String>> questionOptions = new HashMap<>();
    Map<Integer, String> correctAnswers = new HashMap<>();
    Map<Integer, Integer> correctIndexes = new HashMap<>();

    for (int i = 0; i < studiedKanjiList.size(); i++) {
        KanjiDTO currentKanji = studiedKanjiList.get(i);
        List<String> options = new ArrayList<>();

        // 정답 읽기 가져오기
        String correctReading = "";
        if (currentKanji.getOnyomi1() != null && !currentKanji.getOnyomi1().isEmpty()) {
            correctReading = currentKanji.getOnyomi1();
        } else if (currentKanji.getKunyomi1() != null && !currentKanji.getKunyomi1().isEmpty()) {
            correctReading = currentKanji.getKunyomi1();
        }
        options.add(correctReading);
        correctAnswers.put(i, correctReading);

        // 오답 선택지 3개 생성
        List<String> wrongOptions = new ArrayList<>();
        for (KanjiDTO wrongKanji : allKanjiList) {
            if (wrongKanji.getKanjiID() == currentKanji.getKanjiID()) {
                continue;
            }

            String reading = "";
            if (wrongKanji.getOnyomi1() != null && !wrongKanji.getOnyomi1().isEmpty()) {
                reading = wrongKanji.getOnyomi1();
            } else if (wrongKanji.getKunyomi1() != null && !wrongKanji.getKunyomi1().isEmpty()) {
                reading = wrongKanji.getKunyomi1();
            }
            
            if (!reading.isEmpty() && !wrongOptions.contains(reading) && !reading.equals(correctReading)) {
                wrongOptions.add(reading);
            }

            if (wrongOptions.size() >= 3) {
                break;
            }
        }

        options.addAll(wrongOptions);
        Collections.shuffle(options);
        
        // 정답의 인덱스 저장
        correctIndexes.put(i, options.indexOf(correctReading));
        questionOptions.put(i, options);
    }
%>

    <div class="container">
        <form id="testForm" action="WrongKanjiTestCon.do" method="post">
            <input type="hidden" name="level" value="<%= level != null ? level : "" %>">
            <input type="hidden" name="sector" value="<%= sector %>">
           <input type="hidden" name="totalQuestions" value="<%= studiedKanjiList.size() %>">
            <input type="hidden" name="mode" value="<%= isWrongMode ? "wrong" : "" %>">

            <% for (int i = 0; i < studiedKanjiList.size(); i++) { 
                KanjiDTO kanji = studiedKanjiList.get(i);
                List<String> options = questionOptions.get(i);
                int correctIdx = correctIndexes.get(i);
            %>
            <div class="question-container" id="question_<%= i %>" style="<%= i == 0 ? "" : "display:none;" %>" data-correct-index="<%= correctIdx %>" data-correct-answer="<%= correctAnswers.get(i) %>">
               <div class="progress">
                    <span><%= i + 1 %>/<%= studiedKanjiList.size() %></span>
                    <span class="score"><%= isWrongMode ? "오답" : "복습" %></span>
                </div>

                <div class="kanji-display"><%= kanji.getKanji() %></div>

                <div class="options">
                    <% for (int j = 0; j < options.size(); j++) { %>
                    <button type="button" class="option-btn" data-index="<%= j %>" onclick="selectAnswer(<%= i %>, <%= j %>, '<%= options.get(j) %>')">
                        <%= options.get(j) %>
                    </button>
                    <% } %>
                </div>

                <input type="hidden" name="kanjiID_<%= i %>" value="<%= kanji.getKanjiID() %>">
                <input type="hidden" name="correctAnswer_<%= i %>" value="<%= correctAnswers.get(i) %>">
                <input type="hidden" name="answer_<%= i %>" id="answer_<%= i %>">

                <% if (i < studiedKanjiList.size() - 1) { %>
                <button type="button" class="submit-btn" id="nextBtn_<%= i %>" onclick="passQuestion(<%= i %>)">
                    모르겠어요
                </button>
                <% } else { %>
                <button type="button" class="submit-btn" id="finalBtn_<%= i %>" onclick="handleFinalQuestion(<%= i %>)">
                    모르겠어요
                </button>
                <% } %>

                <div class="question-info">
                    이 한자의 뜻은 무엇인가요?
                </div>
            </div>
            <% } %>
        </form>
    </div>

    <script>
        var totalQuestions = <%= studiedKanjiList.size() %>;
        
        function selectAnswer(questionIndex, optionIndex, answer) {
            document.getElementById('answer_' + questionIndex).value = answer;
            
            var container = document.getElementById('question_' + questionIndex);
            var buttons = container.querySelectorAll('.option-btn');
            var correctIdx = parseInt(container.getAttribute('data-correct-index'));
            
            // 모든 버튼 비활성화
            buttons.forEach(function(btn) {
                btn.disabled = true;
                btn.style.pointerEvents = 'none';
            });
            
            // 정답/오답 표시
            if (optionIndex === correctIdx) {
                buttons[optionIndex].style.background = '#4CAF50';
                buttons[optionIndex].style.color = 'white';
            } else {
                buttons[optionIndex].style.background = '#f44336';
                buttons[optionIndex].style.color = 'white';
                buttons[correctIdx].style.background = '#4CAF50';
                buttons[correctIdx].style.color = 'white';
            }
            
            // 1초 후 다음 문제로
            setTimeout(function() {
                if (questionIndex < totalQuestions - 1) {
                    document.getElementById('question_' + questionIndex).style.display = 'none';
                    document.getElementById('question_' + (questionIndex + 1)).style.display = '';
                } else {
                    document.getElementById('testForm').submit();
                }
            }, 1000);
        }
        
        function passQuestion(questionIndex) {
            document.getElementById('answer_' + questionIndex).value = '';
            
            var container = document.getElementById('question_' + questionIndex);
            var buttons = container.querySelectorAll('.option-btn');
            var correctIdx = parseInt(container.getAttribute('data-correct-index'));
            
            // 모든 버튼 비활성화
            buttons.forEach(function(btn) {
                btn.disabled = true;
                btn.style.pointerEvents = 'none';
            });
            
            // 정답 초록색 표시
            buttons[correctIdx].style.background = '#4CAF50';
            buttons[correctIdx].style.color = 'white';
            
            // 모르겠어요 버튼 비활성화
            document.getElementById('nextBtn_' + questionIndex).disabled = true;
            
            // 1초 후 다음 문제로
            setTimeout(function() {
                document.getElementById('question_' + questionIndex).style.display = 'none';
                document.getElementById('question_' + (questionIndex + 1)).style.display = '';
            }, 1000);
        }
        
        function handleFinalQuestion(questionIndex) {
            document.getElementById('answer_' + questionIndex).value = '';
            
            var container = document.getElementById('question_' + questionIndex);
            var buttons = container.querySelectorAll('.option-btn');
            var correctIdx = parseInt(container.getAttribute('data-correct-index'));
            
            // 모든 버튼 비활성화
            buttons.forEach(function(btn) {
                btn.disabled = true;
                btn.style.pointerEvents = 'none';
            });
            
            // 정답 초록색 표시
            buttons[correctIdx].style.background = '#4CAF50';
            buttons[correctIdx].style.color = 'white';
            
            // 모르겠어요 버튼 비활성화
            document.getElementById('finalBtn_' + questionIndex).disabled = true;
            
            // 1초 후 제출
            setTimeout(function() {
                document.getElementById('testForm').submit();
            }, 1000);
        }
    </script>
</body>
</html>