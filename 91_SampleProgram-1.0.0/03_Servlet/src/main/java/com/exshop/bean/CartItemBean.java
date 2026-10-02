package com.exshop.bean;

import java.io.Serializable;

public class CartItemBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private ProductBean product;
    private int quantity;
    private int price;

    public CartItemBean(ProductBean product, int quantity) {
        this.product = product;
        this.quantity = quantity;
        this.price = product.getPrice();
    }

    public ProductBean getProduct() { return product; }
    public void setProduct(ProductBean product) { this.product = product; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public int getSubtotal() { return price * quantity; }
}
