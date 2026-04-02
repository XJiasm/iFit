package com.fitmirror.repository;

import com.fitmirror.entity.ClothItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ClothItemRepository extends JpaRepository<ClothItem, Long> {
    List<ClothItem> findByUserId(Long userId);
    List<ClothItem> findByUserIdAndType(Long userId, String type);
    List<ClothItem> findByUserIdAndStatus(Long userId, String status);
}
