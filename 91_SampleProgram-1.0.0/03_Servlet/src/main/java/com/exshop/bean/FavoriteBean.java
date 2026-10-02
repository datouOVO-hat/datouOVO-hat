package com.exshop.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class FavoriteBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private int productId;
    private Timestamp createdAt;
    private ProductBean product;

    public FavoriteBean() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public ProductBean getProduct() { return product; }
    public void setProduct(ProductBean product) { this.product = product; }
}
