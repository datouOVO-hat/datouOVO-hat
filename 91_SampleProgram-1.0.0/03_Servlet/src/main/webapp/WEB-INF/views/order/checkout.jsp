<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ご注文手続き - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <h2 class="brand-font mb-4"><i class="bi bi-credit-card-2-front me-2 brand-gold"></i>お届け先・お支払い情報</h2>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card luxury-card p-4 shadow-sm">
                <form method="post" action="${pageContext.request.contextPath}/checkout">
                    <div class="mb-3">
                        <label class="form-label fw-bold">お名前 <span class="text-danger">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<c:out value='${sessionScope.loginUser.fullName}'/>" placeholder="山田 太郎" required>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">メールアドレス <span class="text-danger">*</span></label>
                            <input type="email" name="email" class="form-control" value="<c:out value='${sessionScope.loginUser.email}'/>" placeholder="yamada@example.com" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">電話番号 <span class="text-danger">*</span></label>
                            <input type="text" name="phoneNumber" class="form-control" placeholder="090-1234-5678" required>
                        </div>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">郵便番号 <span class="text-danger">*</span></label>
                            <input type="text" name="postalCode" class="form-control" placeholder="100-0001" required>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-bold">お届け先住所 <span class="text-danger">*</span></label>
                            <input type="text" name="address" class="form-control" placeholder="東京都千代田区千代田1-1" required>
                        </div>
                    </div>

                    <hr class="my-4">

                    <h5 class="brand-font mb-3">お支払い方法</h5>
                    <div class="mb-4">
                        <select name="paymentMethod" class="form-select">
                            <option value="credit_card">クレジットカード決済</option>
                            <option value="bank_transfer">銀行振込 (前払い)</option>
                            <option value="cod">代金引換</option>
                            <option value="convenience">コンビニエンスストア決済</option>
                        </select>
                    </div>

                    <div class="d-flex justify-content-between pt-3 border-top">
                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary rounded-pill px-4">バッグに戻る</a>
                        <button type="submit" class="btn btn-gold btn-lg rounded-pill px-5 fw-bold shadow-sm">注文を確定する</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card luxury-card p-4 shadow-sm">
                <h5 class="brand-font mb-3">ご注文商品 (${cart.totalCount} 点)</h5>
                <c:forEach var="item" items="${cart.items}">
                    <div class="d-flex align-items-center gap-3 py-2 border-bottom">
                        <img src="${pageContext.request.contextPath}/${item.product.imageUrl}" class="rounded border" style="width: 48px; height: 48px; object-fit: cover;">
                        <div class="flex-grow-1 text-truncate">
                            <div class="fw-bold small text-truncate"><c:out value="${item.product.name}"/></div>
                            <span class="text-muted small">&yen;<fmt:formatNumber value="${item.price}" pattern="#,###"/> &times; ${item.quantity}</span>
                        </div>
                        <div class="fw-bold price-gold">&yen;<fmt:formatNumber value="${item.subtotal}" pattern="#,###"/></div>
                    </div>
                </c:forEach>
                <div class="d-flex justify-content-between align-items-baseline pt-3">
                    <span class="fw-bold">合計お支払い金額</span>
                    <span class="fs-4 price-gold">&yen;<fmt:formatNumber value="${cart.totalPrice}" pattern="#,###"/></span>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
