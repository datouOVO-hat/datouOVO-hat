<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ログイン - exShop Luxury"/>
</jsp:include>

<div class="container py-5" style="max-width: 440px;">
    <div class="card luxury-card p-4 shadow-sm">
        <h3 class="brand-font text-center mb-3">MEMBER LOGIN</h3>
        <p class="text-muted small text-center mb-4">会員アカウントでサインイン</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger small"><c:out value="${errorMessage}"/></div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/auth/login">
            <div class="mb-3">
                <label class="form-label fw-bold small">ユーザー名</label>
                <input type="text" name="username" class="form-control" required autofocus>
            </div>
            <div class="mb-4">
                <label class="form-label fw-bold small">パスワード</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-gold w-100 rounded-pill py-2 fw-bold shadow-sm">ログイン</button>
        </form>

        <div class="text-center mt-4 pt-3 border-top small">
            <span class="text-muted">アカウントをお持ちでない方は</span>
            <a href="${pageContext.request.contextPath}/auth/signup" class="price-gold fw-bold ms-1 text-decoration-none">新規サロン登録</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
