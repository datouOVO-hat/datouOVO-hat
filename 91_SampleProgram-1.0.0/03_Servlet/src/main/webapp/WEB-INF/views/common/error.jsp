<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="エラー - exShop Luxury"/>
</jsp:include>

<div class="container py-5 text-center" style="max-width: 600px;">
    <div class="card luxury-card p-5">
        <i class="bi bi-exclamation-triangle-fill text-warning fs-1 mb-3"></i>
        <h3 class="brand-font mb-3">エラーが発生いたしました</h3>
        <p class="text-muted mb-4"><c:out value="${errorMessage != null ? errorMessage : 'リクエストの処理中に問題が生じました。'}"/></p>
        <div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-gold rounded-pill px-4">トップページへ戻る</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
