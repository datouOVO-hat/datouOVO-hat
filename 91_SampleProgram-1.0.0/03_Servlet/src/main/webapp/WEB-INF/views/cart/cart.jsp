<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="ショッピングバッグ - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <h2 class="brand-font mb-4"><i class="bi bi-bag-check me-2 brand-gold"></i>ショッピングバッグ</h2>

    <c:choose>
        <c:when test="${not cart.empty}">
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card luxury-card shadow-sm overflow-hidden">
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>アイテム</th>
                                        <th class="text-center">単価</th>
                                        <th class="text-center" style="width: 140px;">数量</th>
                                        <th class="text-end">小計</th>
                                        <th class="text-center" style="width: 60px;"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${cart.items}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-3">
                                                    <img src="${pageContext.request.contextPath}/${item.product.imageUrl}" class="rounded border" style="width: 60px; height: 60px; object-fit: cover;">
                                                    <div>
                                                        <h6 class="fw-bold mb-1">
                                                            <a href="${pageContext.request.contextPath}/products/detail?id=${item.product.id}" class="text-dark text-decoration-none">
                                                                <c:out value="${item.product.name}"/>
                                                            </a>
                                                        </h6>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-center">&yen;<fmt:formatNumber value="${item.price}" pattern="#,###"/></td>
                                            <td class="text-center">
                                                <form action="${pageContext.request.contextPath}/cart/update" method="post" class="d-inline-flex">
                                                    <input type="hidden" name="productId" value="${item.product.id}">
                                                    <select name="quantity" class="form-select form-select-sm" onchange="this.form.submit()">
                                                        <c:forEach var="i" begin="1" end="10">
                                                            <option value="${i}" ${item.quantity == i ? 'selected' : ''}>${i}</option>
                                                        </c:forEach>
                                                    </select>
                                                </form>
                                            </td>
                                            <td class="text-end fw-bold price-gold">&yen;<fmt:formatNumber value="${item.subtotal}" pattern="#,###"/></td>
                                            <td class="text-center">
                                                <form action="${pageContext.request.contextPath}/cart/remove" method="post">
                                                    <input type="hidden" name="productId" value="${item.product.id}">
                                                    <button type="submit" class="btn btn-sm btn-link text-danger p-0"><i class="bi bi-trash3"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card luxury-card p-4 shadow-sm">
                        <h5 class="brand-font mb-3">ご注文概要</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">小計</span>
                            <span class="fw-bold">&yen;<fmt:formatNumber value="${cart.totalPrice}" pattern="#,###"/></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">配送料</span>
                            <span class="text-success fw-bold">無料 (会員特典)</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between align-items-baseline mb-4">
                            <span class="fw-bold fs-5">合計</span>
                            <span class="display-6 price-gold">&yen;<fmt:formatNumber value="${cart.totalPrice}" pattern="#,###"/></span>
                        </div>

                        <a href="${pageContext.request.contextPath}/checkout" class="btn btn-gold btn-lg w-100 rounded-pill shadow-sm">
                            ご注文手続きへ進む <i class="bi bi-chevron-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card luxury-card py-5 text-center shadow-sm">
                <i class="bi bi-bag-x fs-1 text-muted mb-3"></i>
                <h4 class="brand-font mb-2">ショッピングバッグは空です</h4>
                <p class="text-muted mb-4">お気に入りのアイテムを見つけてみませんか？</p>
                <div>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-gold rounded-pill px-5">コレクションへ戻る</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
