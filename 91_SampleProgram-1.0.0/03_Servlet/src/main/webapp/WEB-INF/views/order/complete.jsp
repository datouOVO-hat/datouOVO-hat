<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ご注文完了 - exShop Luxury"/>
</jsp:include>

<div class="container py-5 text-center" style="max-width: 650px;">
    <div class="card luxury-card p-5 shadow-sm">
        <i class="bi bi-check-circle-fill text-success fs-1 mb-3"></i>
        <h2 class="brand-font mb-2">ご注文ありがとうございます</h2>
        <p class="text-muted mb-4">ご注文手続きが滞りなく完了いたしました。</p>

        <div class="p-3 bg-light rounded text-start mb-4 border">
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">注文番号:</span>
                <span class="fw-bold">#<c:out value="${order.orderNumber}"/></span>
            </div>
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">お支払い方法:</span>
                <span>${order.paymentMethodLabel}</span>
            </div>
            <div class="d-flex justify-content-between">
                <span class="text-muted">合計金額:</span>
                <span class="price-gold fs-5">&yen;<fmt:formatNumber value="${order.totalPrice}" pattern="#,###"/></span>
            </div>
        </div>

        <div class="d-flex justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-gold rounded-pill px-4">コレクションへ</a>
            <c:if test="${not empty sessionScope.loginUser}">
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-outline-secondary rounded-pill px-4">ご注文履歴</a>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
