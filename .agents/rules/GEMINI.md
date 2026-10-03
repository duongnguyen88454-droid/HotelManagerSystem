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
- Trước khi sửa bất kỳ file .java nào, phải đọc .agents/rules/ARCHITECTURE_RULES.md và tuân thủ.

## 2. Quy Ước Kiểm Thử (Testing Convention) - Tuyệt Đối Không Sửa Test Để Pass
- **NGHIÊM CẤM SỬA TEST CASE KHI FAIL:** Khi một test case (ArchUnit, JUnit, Integration test, SQL test script, v.v.) bị **FAIL**, tuyệt đối **KHÔNG ĐƯỢC PHÉP** chỉnh sửa logic của test case, đổi assertion, giảm nhẹ tiêu chuẩn kiểm tra, bỏ qua (skip/ignore/@Disabled) hoặc sửa dữ liệu kỳ vọng chỉ nhằm mục đích làm cho test case chuyển sang màu xanh (PASS).
- **NGUYÊN TẮC XỬ LÝ TEST FAIL:**
  1. Thừa nhận trung thực kết quả test fail, ghi nhận rõ thông báo lỗi và file/dòng gây lỗi.
  2. Phân tích nguyên nhân gốc rễ (Root Cause) nằm ở mã nguồn thực thi hoặc logic nghiệp vụ.
  3. Lập đề xuất sửa **mã nguồn thực thi** (hoặc cấu trúc hệ thống) để thỏa mãn đúng yêu cầu mà test case đang bảo vệ.
  4. **Ngoại lệ duy nhất:** Chỉ được phép sửa test case khi chính User xác nhận rằng yêu cầu nghiệp vụ đã thay đổi hoặc test case ban đầu được viết sai logic thực tế, và User có hiệu lệnh yêu cầu cập nhật test case.

