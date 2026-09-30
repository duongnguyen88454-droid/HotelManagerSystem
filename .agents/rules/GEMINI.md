# QUY TẮC BẮT BUỘC: ĐỀ XUẤT - THẨM ĐỊNH - DUYỆT TRƯỚC KHI CODE

## 1. Nguyên Tắc Tuyệt Đối
- **KHÔNG ĐƯỢC PHÉP TỰ Ý SỬA CODE:** Tuyệt đối không gọi các công cụ sửa file mã nguồn (`replace_file_content`, `multi_replace_file_content`, `write_to_file` trên các file `.java`, `.jsp`, `.sql`, `.js`, `.css`, v.v.) khi User chưa đọc giải pháp và chưa đưa ra hiệu lệnh cho phép rõ ràng.
- **KHI PHÁT HIỆN LỖI HOẶC ĐỀ XUẤT THAY ĐỔI:**
  1. Nêu rõ vấn đề/lỗi là gì và nguyên nhân ở đâu (kèm file và số dòng).
  2. Trình bày phương án giải quyết và logic khắc phục.
  3. Cung cấp đoạn code so sánh **Trước khi sửa (Before)** và **Sau khi sửa (After)**.
  4. Ghi nhận vào file báo cáo `.md` riêng nếu User yêu cầu.
  5. **DỪNG LẠI HOÀN TOÀN** để chờ User đọc, thẩm định và duyệt.
- **CHỈ KHI NÀO USER NÓI ĐỒNG Ý / CHO PHÉP CODE:** Lúc đó mới được phép thực thi chỉnh sửa code, rebuild và chạy lại test case để kiểm chứng.
