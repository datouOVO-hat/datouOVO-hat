<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ご注文履歴 - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <h2 class="brand-font mb-4"><i class="bi bi-receipt me-2 brand-gold"></i>お客様のご注文履歴</h2>

    <c:choose>
        <c:when test="${not empty orders}">
            <div class="card luxury-card shadow-sm overflow-hidden">
                <table class="table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>注文番号</th>
                            <th>ご注文日時</th>
                            <th>品目数</th>
                            <th>お支払方法</th>
                            <th class="text-end">合計金額</th>
                            <th class="text-center">状態</th>
                            <th class="text-center">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="o" items="${orders}">
                            <tr>
                                <td class="fw-bold">#<c:out value="${o.orderNumber}"/></td>
                                <td class="text-muted small">${o.createdAt}</td>
                                <td>${o.items.size()} 点</td>
                                <td><span class="badge bg-light text-dark border">${o.paymentMethodLabel}</span></td>
                                <td class="text-end price-gold">&yen;<fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/></td>
                                <td class="text-center"><span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">${o.statusLabel}</span></td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/orders/detail?orderNumber=${o.orderNumber}" class="btn btn-sm btn-outline-dark rounded-pill px-3">詳細</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card luxury-card py-5 text-center shadow-sm">
                <p class="text-muted mb-3">ご注文履歴はございません。</p>
                <div><a href="${pageContext.request.contextPath}/products" class="btn btn-gold rounded-pill px-4">コレクションを見る</a></div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
