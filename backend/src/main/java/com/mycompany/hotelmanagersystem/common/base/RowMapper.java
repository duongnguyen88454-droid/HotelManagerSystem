package com.mycompany.hotelmanagersystem.common.base;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Functional Interface định nghĩa quy tắc ánh xạ một dòng trong ResultSet
 * thành một đối tượng dữ liệu cụ thể (Entity / Model / DTO).
 *
 * @param <T> Kiểu đối tượng đích
 */
@FunctionalInterface
public interface RowMapper<T> {

    /**
     * Chuyển đổi dòng hiện tại của ResultSet sang đối tượng kiểu T.
     *
     * @param rs Con trỏ ResultSet đang trỏ tới dòng hiện tại
     * @return Đối tượng được khởi tạo từ dòng dữ liệu
     * @throws SQLException khi có lỗi truy xuất cột dữ liệu
     */
    T mapRow(ResultSet rs) throws SQLException;
}
