<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ウィッシュリスト - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <h2 class="brand-font mb-4"><i class="bi bi-suit-heart me-2 brand-gold"></i>ウィッシュリスト (お気に入り)</h2>

    <c:choose>
        <c:when test="${not empty favorites}">
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
                <c:forEach var="fav" items="${favorites}">
                    <div class="col">
                        <div class="card luxury-card h-100 p-2 text-center position-relative">
                            <form action="${pageContext.request.contextPath}/favorites/toggle" method="post" class="position-absolute" style="top: 10px; right: 10px; z-index: 5;">
                                <input type="hidden" name="productId" value="${fav.product.id}">
                                <button type="submit" class="btn btn-sm btn-light rounded-circle shadow-sm" title="削除">
                                    <i class="bi bi-suit-heart-fill text-danger"></i>
                                </button>
                            </form>
                            <a href="${pageContext.request.contextPath}/products/detail?id=${fav.product.id}" class="text-decoration-none">
                                <img src="${pageContext.request.contextPath}/${fav.product.imageUrl}" class="img-fluid rounded mb-2" style="height: 180px; width: 100%; object-fit: cover;">
                                <div class="text-dark fw-bold small text-truncate"><c:out value="${fav.product.name}"/></div>
                                <div class="price-gold fs-6 mt-1">&yen;<fmt:formatNumber value="${fav.product.price}" pattern="#,###"/></div>
                            </a>
                            <c:if test="${fav.product.inStock}">
                                <form action="${pageContext.request.contextPath}/cart/add" method="post" class="mt-2">
                                    <input type="hidden" name="productId" value="${fav.product.id}">
                                    <input type="hidden" name="quantity" value="1">
                                    <button type="submit" class="btn btn-gold btn-sm w-100 rounded-pill">バッグへ</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card luxury-card py-5 text-center shadow-sm">
                <p class="text-muted mb-3">ウィッシュリストにアイテムはございません。</p>
                <div><a href="${pageContext.request.contextPath}/products" class="btn btn-gold rounded-pill px-4">アイテムを探す</a></div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
