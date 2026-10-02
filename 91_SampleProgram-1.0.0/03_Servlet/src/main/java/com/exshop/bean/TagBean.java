package com.exshop.bean;

import java.io.Serializable;

public class TagBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String slug;
    private String color;
    private int productCount;

    public TagBean() {}

    public TagBean(int id, String name, String slug, String color) {
        this.id = id;
        this.name = name;
        this.slug = slug;
        this.color = color;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
}
