package com.exshop.bean;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ProductBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String description;
    private int price;
    private int stock;
    private String image;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<TagBean> tags = new ArrayList<>();

    public ProductBean() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    /**
     * 画像が未登録、または空文字の場合は no-image.png を返す
     */
    public String getImageUrl() {
        if (image != null && !image.trim().isEmpty()) {
            return "media/" + image;
        }
        return "media/no-image.png";
    }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public List<TagBean> getTags() { return tags; }
    public void setTags(List<TagBean> tags) { this.tags = tags; }

    public boolean isInStock() { return stock > 0; }
}
