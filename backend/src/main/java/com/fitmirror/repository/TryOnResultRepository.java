package com.fitmirror.repository;

import com.fitmirror.entity.TryOnResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TryOnResultRepository extends JpaRepository<TryOnResult, Long> {
    List<TryOnResult> findByUserId(Long userId);
    List<TryOnResult> findByAvatarId(Long avatarId);
    List<TryOnResult> findByClothItemId(Long clothItemId);
}
