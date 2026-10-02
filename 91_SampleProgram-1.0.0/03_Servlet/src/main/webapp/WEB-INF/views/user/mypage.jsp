<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="マイページ - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <div class="card luxury-card p-4 shadow-sm mb-4">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
            <div>
                <h3 class="brand-font mb-1"><c:out value="${sessionScope.loginUser.username}"/> 様</h3>
                <p class="text-muted small mb-0"><c:out value="${sessionScope.loginUser.email}"/></p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/products/create" class="btn btn-gold rounded-pill px-4 me-2">新作を出品</a>
                <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-outline-danger rounded-pill px-3">ログアウト</a>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card luxury-card p-4 shadow-sm h-100">
                <h5 class="brand-font mb-3">直近のご注文</h5>
                <c:choose>
                    <c:when test="${not empty recentOrders}">
                        <ul class="list-group list-group-flush">
                            <c:forEach var="o" items="${recentOrders}">
                                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                    <div>
                                        <div class="fw-bold">#<c:out value="${o.orderNumber}"/></div>
                                        <div class="text-muted small">${o.createdAt}</div>
                                    </div>
                                    <div class="text-end">
                                        <div class="price-gold">&yen;<fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/></div>
                                        <a href="${pageContext.request.contextPath}/orders/detail?orderNumber=${o.orderNumber}" class="btn btn-sm btn-outline-dark rounded-pill mt-1">詳細</a>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted small">ご注文履歴はございません。</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card luxury-card p-4 shadow-sm h-100">
                <h5 class="brand-font mb-3">ウィッシュリスト</h5>
                <c:choose>
                    <c:when test="${not empty favorites}">
                        <div class="row row-cols-2 g-2">
                            <c:forEach var="fav" items="${favorites}">
                                <div class="col">
                                    <a href="${pageContext.request.contextPath}/products/detail?id=${fav.product.id}" class="text-decoration-none">
                                        <div class="border rounded p-2 text-center">
                                            <img src="${pageContext.request.contextPath}/${fav.product.imageUrl}" class="rounded mb-1" style="width: 100%; height: 80px; object-fit: cover;">
                                            <div class="text-dark small text-truncate fw-bold"><c:out value="${fav.product.name}"/></div>
                                            <div class="price-gold small">&yen;<fmt:formatNumber value="${fav.product.price}" pattern="#,###"/></div>
                                        </div>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted small">ウィッシュリストは空です。</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
