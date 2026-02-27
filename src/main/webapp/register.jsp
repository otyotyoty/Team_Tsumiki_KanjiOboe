<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
        <link rel="stylesheet" href="css/login_register.css">
    
    <style>
    
    
        .error { color: red; }
    </style>
</head>
<body>


<div class="signup-container">
    <h3>회원가입</h3>
    <h1>재미있게 즐기는 일본어 공부, 지금 바로 시작해 보세요!</h1>

    <%
        String error = request.getParameter("error");
        if ("empty".equals(error)) {
    %>
        <p class="error">모든 항목을 입력해주세요.</p>
    <%
        } else if ("id".equals(error)) {
    %>
        <p class="error">이미 존재하는 아이디입니다.</p>
    <%
        } else if ("nickname".equals(error)) {
    %>
        <p class="error">이미 사용 중인 닉네임입니다.</p>
    <%
        } else if ("pw".equals(error)) {
    %>
        <p class="error">비밀번호가 일치하지 않습니다.</p>
    <%
        }
    %>

    <form action="RegisterCon.do" method="post">
        <div class="form-group">
            <input type="text" name="nickname" placeholder="닉네임" required>
        </div>

        <div class="form-group">
            <input type="email" name="email" placeholder="이메일 (아이디)" required>
        </div>

        <div class="form-group">
            <input type="password" name="userPw" placeholder="비밀번호" required>
        </div>

        <div class="form-group">
            <input type="password" name="userPw2" placeholder="비밀번호 확인" required>
        </div>

        <button type="submit" class="btn-submit">가입하기</button>
    </form>

    <div class="login-link">
        이미 계정이 있으신가요? <a href="login.jsp">로그인</a>
    </div>
</div>

</body>
</html>