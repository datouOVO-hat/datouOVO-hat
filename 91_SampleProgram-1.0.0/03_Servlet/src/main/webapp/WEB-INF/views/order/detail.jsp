<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="注文詳細 #${order.orderNumber} - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="brand-font mb-1">ご注文明細</h2>
            <span class="text-muted small">注文番号: <strong>#<c:out value="${order.orderNumber}"/></strong></span>
        </div>
        <a href="${pageContext.request.contextPath}/orders" class="btn btn-outline-secondary rounded-pill btn-sm px-3">履歴一覧へ</a>
    </div>

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card luxury-card shadow-sm overflow-hidden mb-4">
                <table class="table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>アイテム名</th>
                            <th class="text-center">単価</th>
                            <th class="text-center">数量</th>
                            <th class="text-end">小計</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${order.items}">
                            <tr>
                                <td class="fw-bold"><c:out value="${item.productName}"/></td>
                                <td class="text-center">&yen;<fmt:formatNumber value="${item.price}" pattern="#,###"/></td>
                                <td class="text-center">${item.quantity}</td>
                                <td class="text-end price-gold">&yen;<fmt:formatNumber value="${item.subtotal}" pattern="#,###"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                    <tfoot class="table-light">
                        <tr>
                            <th colspan="3" class="text-end">合計お支払い金額:</th>
                            <td class="text-end fs-5 price-gold">&yen;<fmt:formatNumber value="${order.totalPrice}" pattern="#,###"/></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card luxury-card p-4 shadow-sm">
                <h5 class="brand-font mb-3 border-bottom pb-2">お届け先</h5>
                <dl class="row small mb-0">
                    <dt class="col-4 text-muted">お名前</dt><dd class="col-8 fw-bold">${order.fullName}</dd>
                    <dt class="col-4 text-muted">郵便番号</dt><dd class="col-8">${order.postalCode}</dd>
                    <dt class="col-4 text-muted">ご住所</dt><dd class="col-8">${order.address}</dd>
                    <dt class="col-4 text-muted">お電話</dt><dd class="col-8">${order.phoneNumber}</dd>
                    <dt class="col-4 text-muted">お支払方法</dt><dd class="col-8">${order.paymentMethodLabel}</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
