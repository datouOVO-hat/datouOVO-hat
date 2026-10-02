<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="会員登録 - exShop Luxury"/>
</jsp:include>

<div class="container py-5" style="max-width: 500px;">
    <div class="card luxury-card p-4 shadow-sm">
        <h3 class="brand-font text-center mb-3">MEMBERSHIP</h3>
        <p class="text-muted small text-center mb-4">プレミアムサロンへのご登録</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger small"><c:out value="${errorMessage}"/></div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/auth/signup">
            <div class="mb-3">
                <label class="form-label fw-bold small">ユーザー名 <span class="text-danger">*</span></label>
                <input type="text" name="username" class="form-control" required>
            </div>
            <div class="row g-2 mb-3">
                <div class="col-6">
                    <label class="form-label fw-bold small">姓 <span class="text-danger">*</span></label>
                    <input type="text" name="lastName" class="form-control" placeholder="山田" required>
                </div>
                <div class="col-6">
                    <label class="form-label fw-bold small">名 <span class="text-danger">*</span></label>
                    <input type="text" name="firstName" class="form-control" placeholder="太郎" required>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold small">メールアドレス <span class="text-danger">*</span></label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="mb-4">
                <label class="form-label fw-bold small">パスワード <span class="text-danger">*</span></label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-gold w-100 rounded-pill py-2 fw-bold shadow-sm">会員登録を完了する</button>
        </form>

        <div class="text-center mt-4 pt-3 border-top small">
            <span class="text-muted">既にご登録済みの方は</span>
            <a href="${pageContext.request.contextPath}/auth/login" class="price-gold fw-bold ms-1 text-decoration-none">ログイン</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
