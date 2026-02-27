<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>일본어 한자 공부장</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="${pageContext.request.contextPath}/groupSelect?level=${level}" class="back-link">그룹 선택</a>
            <div class="group-info">
                그룹 <fmt:formatNumber value="${groupNumber}" pattern="00" />
            </div>
            <div class="progress">
                ${currentIndex + 1}/${totalCount}
            </div>
        </div>

        <div class="kanji-card">
            <div class="kanji-korean">
                <c:out value="${currentKanji.explanation}" default="" />
            </div>

            <div class="kanji-character">
                ${currentKanji.kanji}
            </div>

            <div class="kanji-readings">
                <div class="reading-item">
                    <span class="reading-label">음독 : </span>
                    <span class="reading-value">
                        <c:choose>
                            <c:when test="${empty onyomi}">-</c:when>
                            <c:otherwise>${onyomi}</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <div class="reading-item">
                    <span class="reading-label">훈독 : </span>
                    <span class="reading-value">
                        <c:choose>
                            <c:when test="${empty kunyomi}">-</c:when>
                            <c:otherwise>${kunyomi}</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="kanji-meaning">
                <div class="meaning-label">의미 :</div>
                <div class="meaning-value">
                    <c:out value="${currentKanji.korean}" default="" />
                </div>
            </div>

            <div class="kanji-examples">
                <c:forEach var="example" items="${exampleWords}">
                    <div class="example-item">${example}</div>
                </c:forEach>
            </div>
        </div>

        <div class="navigation">
            <button class="nav-button prev-button"
                onclick="location.href='${pageContext.request.contextPath}/study?level=${level}&group=${groupNumber}&index=${currentIndex - 1}'"
                <c:if test="${currentIndex == 0}">disabled</c:if>>
                <span class="nav-arrow">◀</span>
            </button>

            <c:choose>
                <c:when test="${isLastKanji}">
                    <button class="nav-button next-button"
                        onclick="location.href='${pageContext.request.contextPath}/study?level=${level}&group=${groupNumber}&index=0'">
                        <span class="nav-arrow">▶</span>
                    </button>
                </c:when>
                <c:otherwise>
                    <button class="nav-button next-button"
                        onclick="location.href='${pageContext.request.contextPath}/study?level=${level}&group=${groupNumber}&index=${currentIndex + 1}'">
                        <span class="nav-arrow">▶</span>
                    </button>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="button-section">
            <button class="action-button finish-button"
                onclick="location.href='${pageContext.request.contextPath}/finishGroup?level=${level}&group=${groupNumber}'">
                학습 완료</button>
            <button class="action-button home-button"
                onclick="location.href='${pageContext.request.contextPath}/groupSelect?level=${level}'">
                그룹 선택으로</button>
        </div>
    </div>
</body>
</html>
