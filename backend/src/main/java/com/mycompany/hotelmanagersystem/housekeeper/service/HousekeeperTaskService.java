package com.mycompany.hotelmanagersystem.housekeeper.service;

import com.mycompany.hotelmanagersystem.housekeeper.dao.DamageReportDAO;
import com.mycompany.hotelmanagersystem.housekeeper.dao.HousekeeperTaskDAO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageCategoryDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageDetailItemDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.HousekeeperTaskDTO;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Service xử lý nghiệp vụ quản lý danh sách nhiệm vụ buồng phòng.
 */
public class HousekeeperTaskService {

    private final HousekeeperTaskDAO taskDAO;
    private final DamageReportDAO damageReportDAO;

    public HousekeeperTaskService() {
        this.taskDAO = new HousekeeperTaskDAO();
        this.damageReportDAO = new DamageReportDAO();
    }

    public HousekeeperTaskService(HousekeeperTaskDAO taskDAO, DamageReportDAO damageReportDAO) {
        this.taskDAO = taskDAO;
        this.damageReportDAO = damageReportDAO;
    }

    /**
     * Lấy danh sách nhiệm vụ dọn phòng theo điều kiện lọc trạng thái.
     */
    public List<HousekeeperTaskDTO> getTaskList(String statusFilter) {
        try {
            return taskDAO.getTasks(statusFilter);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /**
     * Lấy chi tiết một nhiệm vụ theo mã.
     */
    public HousekeeperTaskDTO getTaskDetails(String maNhiemVu) {
        if (maNhiemVu == null || maNhiemVu.trim().isEmpty()) {
            return null;
        }
        return taskDAO.getTaskById(maNhiemVu.trim());
    }

    /**
     * Lấy toàn bộ danh mục loại hư hại từ CSDL.
     */
    public List<DamageCategoryDTO> getDamageCategories() {
        return damageReportDAO.getAllDamageCategories();
    }

    /**
     * Bắt đầu nhận việc dọn phòng.
     */
    public void startCleaning(String maNhiemVu, String maNV) throws Exception {
        validateTaskAndEmployee(maNhiemVu, maNV);
        taskDAO.updateTaskProgress(maNhiemVu.trim(), maNV.trim(), "NhanViec", "KhongThietHai");
    }

    /**
     * Hoàn tất dọn phòng sạch sẽ.
     */
    public void completeClean(String maNhiemVu, String maNV) throws Exception {
        validateTaskAndEmployee(maNhiemVu, maNV);
        taskDAO.updateTaskProgress(maNhiemVu.trim(), maNV.trim(), "HoanThanh", "KhongThietHai");
    }

    /**
     * Lập biên bản báo cáo hư hại đa mục và khóa phòng chuyển sang Damaged.
     */
    public void submitDamageReport(String maNhiemVu, String maNV, String moTaChung,
                                   List<DamageDetailItemDTO> damageItems) throws Exception {
        validateTaskAndEmployee(maNhiemVu, maNV);
        if (damageItems == null || damageItems.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng thêm ít nhất một mục hư hại thiết bị!");
        }

        Set<String> categorySet = new HashSet<>();
        for (DamageDetailItemDTO item : damageItems) {
            if (item.getMaLoaiHuHai() == null || item.getMaLoaiHuHai().trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn loại hư hại cho tất cả các mục!");
            }
            if (!categorySet.add(item.getMaLoaiHuHai().trim())) {
                throw new IllegalArgumentException("Không thể chọn trùng loại hư hại trong cùng một biên bản!");
            }
        }

        damageReportDAO.createDamageReportAndLockRoom(maNhiemVu.trim(), maNV.trim(), moTaChung, damageItems);
    }

    private void validateTaskAndEmployee(String maNhiemVu, String maNV) {
        if (maNhiemVu == null || maNhiemVu.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã nhiệm vụ không hợp lệ!");
        }
        if (maNV == null || maNV.trim().isEmpty()) {
            throw new IllegalArgumentException("Thông tin nhân viên không hợp lệ!");
        }
    }
}
