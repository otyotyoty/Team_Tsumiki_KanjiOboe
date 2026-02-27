<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>로그인</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/login_register.css">
<style>
.error {
	color: red;
}
.success {
	color: green;
}
</style>
</head>
<body>
	<div class="login-container">
		<h3>로그인</h3>
		<h1>오늘의 작은 공부가 내일을 만들어요</h1>

		<c:choose>
			<c:when test="${param.error == 'empty'}">
				<p class="error">아이디와 비밀번호를 전부 입력해주세요.</p>
			</c:when>
			<c:when test="${param.error == 'id'}">
				<p class="error">존재하지 않는 아이디입니다.</p>
			</c:when>
			<c:when test="${param.error == 'pw'}">
				<p class="error">패스워드가 일치하지 않습니다.</p>
			</c:when>
			<c:when test="${param.msg == 'success'}">
				<p class="success">회원가입이 완료되었습니다. 로그인해주세요.</p>
			</c:when>
		</c:choose>

		<form action="${pageContext.request.contextPath}/LoginCon.do" method="post">
			<div class="singup-form-group">
				<input type="email" name="userId" placeholder="이메일" required>
			</div>

			<div class="singup-form-group">
				<input type="password" name="userPw" placeholder="비밀번호" required>
			</div>

			<button type="submit" class="btn-submit">시작하기</button>
		</form>

		<div class="signup-link">
			계정이 없으신가요? <a href="register.jsp">회원가입</a>
		</div>
	</div>
</body>
</html>