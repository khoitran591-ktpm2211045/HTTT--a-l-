-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: localhost:3306
-- Thời gian đã tạo: Th10 09, 2025 lúc 11:18 AM
-- Phiên bản máy phục vụ: 8.0.43
-- Phiên bản PHP: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `truonghoc`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ThongKeTongQuan` ()   BEGIN
    SELECT 
        'Tổng số trường' as chi_tieu,
        COUNT(*) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Tổng số học sinh' as chi_tieu,
        SUM(so_hoc_sinh) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Trung bình học sinh/trường' as chi_tieu,
        ROUND(AVG(so_hoc_sinh), 0) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Trường có nhiều học sinh nhất' as chi_tieu,
        MAX(so_hoc_sinh) as gia_tri
    FROM truong_hoc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TimTruongCoHocSinhLonHon` (IN `so_hoc_sinh_min` INT)   BEGIN
    SELECT 
        th.ma_truong,
        th.ten_truong,
        ch.ten_cap_hoc,
        lt.ten_loai_truong,
        qh.ten_quan_huyen,
        th.dia_chi,
        th.so_hoc_sinh,
        ST_X(th.toa_do) as longitude,
        ST_Y(th.toa_do) as latitude
    FROM truong_hoc th
    JOIN cap_hoc ch ON th.ma_cap_hoc = ch.ma_cap_hoc
    JOIN loai_truong lt ON th.ma_loai_truong = lt.ma_loai_truong
    JOIN quan_huyen qh ON th.ma_quan_huyen = qh.ma_quan_huyen
    WHERE th.so_hoc_sinh > so_hoc_sinh_min
    ORDER BY th.so_hoc_sinh DESC;
END$$

--
-- Các hàm
--
CREATE DEFINER=`root`@`localhost` FUNCTION `KiemTraToaDoCanTho` (`lat` DECIMAL(10,8), `lon` DECIMAL(11,8)) RETURNS TINYINT(1) DETERMINISTIC READS SQL DATA BEGIN
    -- Tọa độ Cần Thơ: 9.8°N - 10.3°N, 105.4°E - 105.9°E
    IF lat BETWEEN 9.8 AND 10.3 AND lon BETWEEN 105.4 AND 105.9 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TinhKhoangCach` (`lat1` DECIMAL(10,8), `lon1` DECIMAL(11,8), `lat2` DECIMAL(10,8), `lon2` DECIMAL(11,8)) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE distance DECIMAL(10,2);
    SET distance = SQRT(POW(69.1 * (lat2 - lat1), 2) + 
                       POW(69.1 * (lon2 - lon1) * COS(lat1 / 57.3), 2));
    RETURN distance;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cap_hoc`
--

CREATE TABLE `cap_hoc` (
  `ma_cap_hoc` varchar(10) NOT NULL,
  `ten_cap_hoc` varchar(50) NOT NULL,
  `thu_tu` int DEFAULT NULL,
  `mo_ta` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `cap_hoc`
--

INSERT INTO `cap_hoc` (`ma_cap_hoc`, `ten_cap_hoc`, `thu_tu`, `mo_ta`) VALUES
('CD', 'Cao đẳng', 5, 'Đào tạo trình độ cao đẳng'),
('DH', 'Đại học', 6, 'Đào tạo trình độ đại học và sau đại học'),
('MN', 'Mầm non', 1, 'Cấp học dành cho trẻ từ 3 tháng đến 6 tuổi'),
('TH', 'Tiểu học', 2, 'Cấp học từ lớp 1 đến lớp 5'),
('THCS', 'THCS', 3, 'Trung học cơ sở từ lớp 6 đến lớp 9'),
('THPT', 'THPT', 4, 'Trung học phổ thông từ lớp 10 đến lớp 12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `co_so_vat_chat`
--

CREATE TABLE `co_so_vat_chat` (
  `ma_co_so` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `loai_co_so` varchar(100) DEFAULT NULL,
  `so_luong` int DEFAULT '0',
  `dien_tich` decimal(10,2) DEFAULT NULL,
  `tinh_trang` varchar(50) DEFAULT NULL,
  `ghi_chu` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `co_so_vat_chat`
--

INSERT INTO `co_so_vat_chat` (`ma_co_so`, `ma_truong`, `loai_co_so`, `so_luong`, `dien_tich`, `tinh_trang`, `ghi_chu`) VALUES
(1, 'DHCT001', 'Phòng học', 500, 25000.00, 'Tốt', 'Phòng học đầy đủ thiết bị'),
(2, 'DHCT001', 'Phòng thí nghiệm', 50, 5000.00, 'Tốt', 'Phòng thí nghiệm hiện đại'),
(3, 'DHCT001', 'Thư viện', 1, 2000.00, 'Tốt', 'Thư viện với 500000 đầu sách'),
(4, 'DHCT001', 'Sân thể thao', 10, 15000.00, 'Tốt', 'Sân bóng đá, bóng rổ, tennis'),
(5, 'THPT001', 'Phòng học', 36, 1800.00, 'Tốt', 'Phòng học 50 chỗ'),
(6, 'THPT001', 'Phòng thí nghiệm', 6, 300.00, 'Tốt', 'Phòng thí nghiệm Lý, Hóa, Sinh'),
(7, 'THPT001', 'Thư viện', 1, 200.00, 'Tốt', 'Thư viện với 10000 đầu sách'),
(8, 'THPT001', 'Sân thể thao', 2, 1000.00, 'Tốt', 'Sân bóng đá và bóng rổ'),
(9, 'THCS001', 'Phòng học', 24, 1200.00, 'Tốt', 'Phòng học 35 chỗ'),
(10, 'THCS001', 'Phòng thí nghiệm', 3, 150.00, 'Tốt', 'Phòng thí nghiệm cơ bản'),
(11, 'THCS001', 'Thư viện', 1, 100.00, 'Tốt', 'Thư viện với 5000 đầu sách'),
(12, 'TH001', 'Phòng học', 30, 900.00, 'Tốt', 'Phòng học 35 chỗ'),
(13, 'TH001', 'Thư viện', 1, 80.00, 'Tốt', 'Thư viện với 3000 đầu sách'),
(14, 'TH001', 'Sân chơi', 1, 500.00, 'Tốt', 'Sân chơi cho học sinh tiểu học'),
(15, 'MN001', 'Phòng học', 12, 360.00, 'Tốt', 'Phòng học 25 chỗ'),
(16, 'MN001', 'Sân chơi', 1, 200.00, 'Tốt', 'Sân chơi an toàn cho trẻ mầm non');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lich_su_thay_doi`
--

CREATE TABLE `lich_su_thay_doi` (
  `ma_lich_su` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `loai_thay_doi` varchar(50) DEFAULT NULL,
  `noi_dung_thay_doi` varchar(1000) DEFAULT NULL,
  `nguoi_thay_doi` varchar(100) DEFAULT NULL,
  `ngay_thay_doi` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `lich_su_thay_doi`
--

INSERT INTO `lich_su_thay_doi` (`ma_lich_su`, `ma_truong`, `loai_thay_doi`, `noi_dung_thay_doi`, `nguoi_thay_doi`, `ngay_thay_doi`) VALUES
(1, 'DHCT001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 42000 lên 45000', 'Admin', '2025-10-09 03:07:06'),
(2, 'THPT001', 'Thay đổi địa chỉ', 'Cập nhật địa chỉ mới: 73 Mậu Thân, Ninh Kiều, Cần Thơ', 'Admin', '2025-10-09 03:07:06'),
(3, 'THCS001', 'Cập nhật số liệu', 'Cập nhật số lớp từ 22 lên 24', 'Admin', '2025-10-09 03:07:06'),
(4, 'TH001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 950 lên 1000', 'Admin', '2025-10-09 03:07:06'),
(5, 'MN001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 280 lên 300', 'Admin', '2025-10-09 03:07:06'),
(6, 'DHCT001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"3/2, Ninh Kiều, Cần Thơ\" thành \"Khu II, đường 3/2, phường Xuân Khánh, quận Ninh Kiều, thành phố Cần Thơ.\"', 'System', '2025-10-09 13:52:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `loai_truong`
--

CREATE TABLE `loai_truong` (
  `ma_loai_truong` varchar(10) NOT NULL,
  `ten_loai_truong` varchar(50) NOT NULL,
  `mo_ta` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `loai_truong`
--

INSERT INTO `loai_truong` (`ma_loai_truong`, `ten_loai_truong`, `mo_ta`) VALUES
('CL', 'Công lập', 'Trường do nhà nước đầu tư và quản lý'),
('CV', 'Chuyên', 'Trường chuyên đào tạo học sinh năng khiếu'),
('LK', 'Liên kết', 'Trường liên kết với các đơn vị trong/ngoài nước'),
('QT', 'Quốc tế', 'Trường theo chương trình quốc tế'),
('TT', 'Tư thục', 'Trường tư nhân');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `quan_huyen`
--

CREATE TABLE `quan_huyen` (
  `ma_quan_huyen` varchar(10) NOT NULL,
  `ten_quan_huyen` varchar(100) NOT NULL,
  `loai_don_vi` varchar(20) DEFAULT NULL,
  `toa_do_trung_tum` point DEFAULT NULL,
  `dien_tich` decimal(10,2) DEFAULT NULL,
  `dan_so` int DEFAULT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL
) ;

--
-- Đang đổ dữ liệu cho bảng `quan_huyen`
--

INSERT INTO `quan_huyen` (`ma_quan_huyen`, `ten_quan_huyen`, `loai_don_vi`, `toa_do_trung_tum`, `dien_tich`, `dan_so`, `ghi_chu`) VALUES
('BT', 'Bình Thủy', 'Quận', 0x000000000101000000ea04341136705a40aa60545227202440, NULL, NULL, NULL),
('CD', 'Cờ Đỏ', 'Huyện', 0x000000000101000000295c8fc2f55c5a4061c3d32b65392440, NULL, NULL, NULL),
('CR', 'Cái Răng', 'Quận', 0x0000000001010000001ea7e8482e735a4043ad69de710a2440, NULL, NULL, NULL),
('NK', 'Ninh Kiều', 'Quận', 0x000000000101000000925cfe43fa715a401ac05b2041112440, NULL, NULL, NULL),
('OM', 'Ô Môn', 'Quận', 0x0000000001010000008126c286a7675a404e62105839342440, NULL, NULL, NULL),
('PD', 'Phong Điền', 'Huyện', 0x000000000101000000a1f831e6ae6d5a40b6847cd0b3592440, NULL, NULL, NULL),
('TL', 'Thới Lai', 'Huyện', 0x000000000101000000c286a757ca625a40933a014d840d2440, NULL, NULL, NULL),
('TN', 'Thốt Nốt', 'Quận', 0x0000000001010000001b0de02d90605a406a4df38e53942440, NULL, NULL, NULL),
('VT', 'Vĩnh Thạnh', 'Huyện', 0x000000000101000000c442ad69de655a40c74b378941e02340, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `thong_ke_truong_theo_cap_hoc`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_cap_hoc` (
`ma_cap_hoc` varchar(10)
,`so_truong` bigint
,`ten_cap_hoc` varchar(50)
,`thu_tu` int
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `thong_ke_truong_theo_loai`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_loai` (
`ma_loai_truong` varchar(10)
,`so_truong` bigint
,`ten_loai_truong` varchar(50)
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `thong_ke_truong_theo_quan_huyen`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_quan_huyen` (
`loai_don_vi` varchar(20)
,`ma_quan_huyen` varchar(10)
,`so_truong` bigint
,`ten_quan_huyen` varchar(100)
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `truong_da_cap`
--

CREATE TABLE `truong_da_cap` (
  `ma_truong_da_cap` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `ma_cap_hoc` varchar(10) NOT NULL,
  `so_lop_cap_hoc` int DEFAULT '0',
  `so_hoc_sinh_cap_hoc` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `truong_da_cap`
--

INSERT INTO `truong_da_cap` (`ma_truong_da_cap`, `ma_truong`, `ma_cap_hoc`, `so_lop_cap_hoc`, `so_hoc_sinh_cap_hoc`) VALUES
(1, 'THPT001', 'THCS', 12, 400),
(2, 'THPT002', 'THCS', 15, 500),
(3, 'THPT003', 'THCS', 12, 400),
(4, 'THCS001', 'TH', 18, 600),
(5, 'THCS002', 'TH', 21, 700);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `truong_hoc`
--

CREATE TABLE `truong_hoc` (
  `ma_truong` varchar(20) NOT NULL,
  `ten_truong` varchar(200) NOT NULL,
  `ma_cap_hoc` varchar(10) NOT NULL,
  `ma_loai_truong` varchar(10) NOT NULL,
  `ma_quan_huyen` varchar(10) NOT NULL,
  `dia_chi` varchar(300) DEFAULT NULL,
  `toa_do` point NOT NULL,
  `so_lop` int DEFAULT '0',
  `so_hoc_sinh` int DEFAULT '0',
  `dien_thoai` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `website` varchar(200) DEFAULT NULL,
  `nam_thanh_lap` int DEFAULT NULL,
  `dien_tich_khuon_vien` decimal(10,2) DEFAULT NULL,
  `trang_thai` varchar(20) DEFAULT 'Hoạt động',
  `ghi_chu` varchar(500) DEFAULT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Đang đổ dữ liệu cho bảng `truong_hoc`
--

INSERT INTO `truong_hoc` (`ma_truong`, `ten_truong`, `ma_cap_hoc`, `ma_loai_truong`, `ma_quan_huyen`, `dia_chi`, `toa_do`, `so_lop`, `so_hoc_sinh`, `dien_thoai`, `email`, `website`, `nam_thanh_lap`, `dien_tich_khuon_vien`, `trang_thai`, `ghi_chu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
('CDCT001', 'Cao đẳng Cần Thơ', 'CD', 'CL', 'NK', '20/30 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a4052b81e85eb112440, 0, 5000, '0292.3832663', 'cdct@ctu.edu.vn', 'www.cdct.edu.vn', 2006, 80000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT002', 'Cao đẳng Y tế Cần Thơ', 'CD', 'CL', 'NK', '126 Nguyễn Thái Học, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a40fa7e6abc74132440, 0, 3000, '0292.3820000', 'info@cdytct.edu.vn', 'www.cdytct.edu.vn', 2005, 40000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT003', 'Cao đẳng Kinh tế - Kỹ thuật Cần Thơ', 'CD', 'CL', 'BT', '57 Nguyễn Văn Cừ, Bình Thủy, Cần Thơ', 0x000000000101000000b81e85eb51705a40e17a14ae47212440, 0, 4000, '0292.3840000', 'info@cdktktct.edu.vn', 'www.cdktktct.edu.vn', 2007, 60000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT004', 'Cao đẳng Kinh tế Đối ngoại (Cơ sở Cần Thơ)', 'CD', 'CL', 'NK', '160 30/4, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a402fdd240681152440, 0, 2500, '0292.3840000', 'cantho@cof.edu.vn', 'cantho.cof.edu.vn', 2010, 30000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT005', 'Cao đẳng FPT Polytechnic (Cơ sở Cần Thơ)', 'CD', 'TT', 'NK', '600 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a40aaf1d24d62102440, 0, 2000, '0292.7307307', 'cantho@fpt.edu.vn', 'cantho.poly.edu.vn', 2017, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT006', 'Cao đẳng Đại Việt Sài Gòn (Cơ sở Cần Thơ)', 'CD', 'TT', 'CR', '168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a4025068195430b2440, 0, 1800, '0292.3840000', 'cantho@dvsg.edu.vn', 'cantho.dvsg.edu.vn', 2015, 20000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT007', 'Cao đẳng Cơ điện và Nông nghiệp Nam Bộ', 'CD', 'CL', 'BT', '57 Nguyễn Văn Cừ, Bình Thủy, Cần Thơ', 0x000000000101000000b81e85eb51705a40fca9f1d24d222440, 0, 2200, '0292.3840000', 'info@cdcennb.edu.vn', 'www.cdcennb.edu.vn', 2008, 35000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT008', 'Cao đẳng Du lịch Cần Thơ', 'CD', 'CL', 'NK', '160 30/4, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a404a0c022b87162440, 0, 1500, '0292.3840000', 'info@cdtct.edu.vn', 'www.cdtct.edu.vn', 2009, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT009', 'Cao đẳng nghề Cần Thơ', 'CD', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a404e62105839342440, 0, 3000, '0292.3840000', 'info@cdnct.edu.vn', 'www.cdnct.edu.vn', 2005, 40000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT010', 'Cao đẳng An Ninh Mạng iSPACE', 'CD', 'TT', 'NK', '160 30/4, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a40643bdf4f8d172440, 0, 1200, '0292.3840000', 'cantho@ispace.edu.vn', 'cantho.ispace.edu.vn', 2016, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('CDCT011', 'Cao đẳng Văn hóa Nghệ thuật Cần Thơ', 'CD', 'CL', 'NK', '160 30/4, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a407f6abc7493182440, 0, 1000, '0292.3840000', 'info@cdvhnact.edu.vn', 'www.cdvhnact.edu.vn', 2012, 20000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT001', 'Đại học Cần Thơ', 'DH', 'CL', 'NK', 'Khu II, đường 3/2, phường Xuân Khánh, quận Ninh Kiều, thành phố Cần Thơ.', 0x000000000101000000925cfe43fa715a401ac05b2041112440, 0, 45000, '02923832663', 'dhct@ctu.edu.vn', 'www.ctu.edu.vn', 1966, 1200000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 13:52:11'),
('DHCT002', 'Đại học Y Dược Cần Thơ', 'DH', 'CL', 'NK', '179 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a4014ae47e17a142440, 0, 12000, '0292.3739204', 'info@ctump.edu.vn', 'www.ctump.edu.vn', 2002, 150000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT003', 'Đại học Tây Đô', 'DH', 'TT', 'BT', '68 Trần Chiên, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a401f85eb51b81e2440, 0, 8000, '0292.3848888', 'info@tdu.edu.vn', 'www.tdu.edu.vn', 2001, 80000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT004', 'Đại học Nam Cần Thơ', 'DH', 'TT', 'CR', '168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a400ad7a3703d0a2440, 0, 6000, '0292.3840000', 'info@nctu.edu.vn', 'www.nctu.edu.vn', 2006, 60000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT005', 'Đại học FPT Cần Thơ', 'DH', 'TT', 'NK', '600 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a408fc2f5285c0f2440, 0, 3000, '0292.7307307', 'cantho@fpt.edu.vn', 'cantho.fpt.edu.vn', 2016, 50000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT006', 'Đại học Kỹ thuật - Công nghệ Cần Thơ', 'DH', 'CL', 'NK', '256 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a4052b81e85eb112440, 0, 15000, '0292.3832663', 'info@ctut.edu.vn', 'www.ctut.edu.vn', 2006, 200000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT007', 'Đại học Greenwich (Cơ sở Cần Thơ)', 'DH', 'LK', 'NK', '160 30/4, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a4014ae47e17a142440, 0, 2000, '0292.7307307', 'cantho@greenwich.edu.vn', 'cantho.greenwich.edu.vn', 2018, 30000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('DHCT008', 'Đại học Kiến trúc TP.HCM (Cơ sở Cần Thơ)', 'DH', 'CL', 'CR', '168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a40cdcccccccc0c2440, 0, 1500, '0292.3840000', 'cantho@uah.edu.vn', 'cantho.uah.edu.vn', 2015, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN001', 'Mầm non Hoa Hồng', 'MN', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a405c8fc2f5281c2440, 12, 300, '0292.3820000', 'hoahong@edu.vn', 'www.hoahong.edu.vn', 1990, 2000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN002', 'Mầm non Hoa Sen', 'MN', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a4004560e2db21d2440, 10, 250, '0292.3820000', 'hoasen@edu.vn', 'www.hoasen.edu.vn', 1992, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN003', 'Mầm non Bình Thủy', 'MN', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40ec51b81e852b2440, 8, 200, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1993, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN004', 'Mầm non Cái Răng', 'MN', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a4014ae47e17a142440, 8, 200, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1994, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN005', 'Mầm non Ô Môn', 'MN', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a407b14ae47e13a2440, 6, 150, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1995, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN006', 'Mầm non Thốt Nốt', 'MN', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a405c8fc2f5289c2440, 6, 150, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1996, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN007', 'Mầm non Phong Điền', 'MN', 'CL', 'PD', '73 Mậu Thân, Phong Điền, Cần Thơ', 0x0000000001010000003d0ad7a3706d5a40e17a14ae47612440, 6, 150, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1997, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN008', 'Mầm non Cờ Đỏ', 'MN', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a400000000000402440, 6, 150, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1998, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN009', 'Mầm non Vĩnh Thạnh', 'MN', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a40295c8fc2f5e82340, 4, 100, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1999, 1000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN010', 'Mầm non Thới Lai', 'MN', 'CL', 'TL', '73 Mậu Thân, Thới Lai, Cần Thơ', 0x000000000101000000c3f5285c8f625a4052b81e85eb112440, 4, 100, '0292.3840000', 'thoilai@edu.vn', 'www.thoilai.edu.vn', 2000, 1000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN011', 'Mầm non Vành Khuyên', 'MN', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a40a4703d0ad7232440, 8, 200, '0292.3820000', 'vanhkhuyen@edu.vn', 'www.vanhkhuyen.edu.vn', 1995, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN012', 'Mầm non Phường An Bình', 'MN', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a40be9f1a2fdd242440, 6, 150, '0292.3820000', 'anbinh@edu.vn', 'www.anbinh.edu.vn', 1997, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN013', 'Mầm non Sao Mai', 'MN', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40ae47e17a142e2440, 6, 150, '0292.3840000', 'saomai@edu.vn', 'www.saomai.edu.vn', 1998, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN014', 'Mầm non Việt Mỹ', 'MN', 'TT', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a406666666666262440, 10, 250, '0292.3820000', 'vietmy@edu.vn', 'www.vietmy.edu.vn', 2005, 2000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN015', 'Mầm non Quốc tế IEC Cần Thơ', 'MN', 'QT', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a400e2db29def272440, 8, 200, '0292.3820000', 'iec@edu.vn', 'www.iec.edu.vn', 2010, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('MN016', 'Mầm non Trường Quốc tế Singapore (SIS)', 'MN', 'QT', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a40295c8fc2f5282440, 8, 200, '0292.3820000', 'sis@edu.vn', 'www.sis.edu.vn', 2012, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH001', 'Tiểu học Nguyễn Thái Học', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a409a99999999192440, 30, 1000, '0292.3820000', 'nguyenthaihoc@edu.vn', 'www.nguyenthaihoc.edu.vn', 1975, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH002', 'Tiểu học Lê Hồng Phong', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a40b4c876be9f1a2440, 27, 900, '0292.3820000', 'lehongphong@edu.vn', 'www.lehongphong.edu.vn', 1978, 5500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH003', 'Tiểu học Trần Phú', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a407f6abc7493182440, 24, 800, '0292.3820000', 'tranphu@edu.vn', 'www.tranphu.edu.vn', 1980, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH004', 'Tiểu học Bình Thủy', 'TH', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40295c8fc2f5282440, 24, 800, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1982, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH005', 'Tiểu học Cái Răng', 'TH', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a4052b81e85eb112440, 21, 700, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1983, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH006', 'Tiểu học Ô Môn', 'TH', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a40b81e85eb51382440, 18, 600, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1985, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH007', 'Tiểu học Thốt Nốt', 'TH', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a409a99999999992440, 21, 700, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1984, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH008', 'Tiểu học Phong Điền', 'TH', 'CL', 'PD', '73 Mậu Thân, Phong Điền, Cần Thơ', 0x0000000001010000003d0ad7a3706d5a401f85eb51b85e2440, 18, 600, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1986, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH009', 'Tiểu học Cờ Đỏ', 'TH', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a403d0ad7a3703d2440, 18, 600, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1987, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH010', 'Tiểu học Vĩnh Thạnh', 'TH', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a406666666666e62340, 15, 500, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1988, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH011', 'Tiểu học Nguyễn Huệ', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a4039b4c876be1f2440, 24, 800, '0292.3820000', 'nguyenhue@edu.vn', 'www.nguyenhue.edu.vn', 1980, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH012', 'Tiểu học Chu Văn An', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a40e17a14ae47212440, 21, 700, '0292.3820000', 'chuvanan@edu.vn', 'www.chuvanan.edu.vn', 1982, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH013', 'Tiểu học An Nghiệp', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a40894160e5d0222440, 21, 700, '0292.3820000', 'annghiep@edu.vn', 'www.annghiep.edu.vn', 1984, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH014', 'Tiểu học Ngô Quyền', 'TH', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000295c8fc2f5705a40a4703d0ad7232440, 18, 600, '0292.3820000', 'ngoquyen@edu.vn', 'www.ngoquyen.edu.vn', 1986, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH015', 'Tiểu học Long Tuyền', 'TH', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40ec51b81e852b2440, 18, 600, '0292.3840000', 'longtuyen@edu.vn', 'www.longtuyen.edu.vn', 1988, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH016', 'Tiểu học Hưng Phú', 'TH', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a4014ae47e17a142440, 18, 600, '0292.3840000', 'hungphu@edu.vn', 'www.hungphu.edu.vn', 1990, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH017', 'Tiểu học Thới Hòa', 'TH', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a407b14ae47e13a2440, 15, 500, '0292.3840000', 'thoihoa@edu.vn', 'www.thoihoa.edu.vn', 1992, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('TH018', 'Tiểu học Nhơn Ái', 'TH', 'CL', 'PD', '73 Mậu Thân, Phong Điền, Cần Thơ', 0x0000000001010000003d0ad7a3706d5a40e17a14ae47612440, 15, 500, '0292.3840000', 'nhonai@edu.vn', 'www.nhonai.edu.vn', 1994, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS001', 'THCS Nguyễn Du', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a40d7a3703d0a172440, 24, 800, '0292.3820000', 'nguyendu@edu.vn', 'www.nguyendu.edu.vn', 1980, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS002', 'THCS Lê Lợi', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a407f6abc7493182440, 27, 900, '0292.3820000', 'leloi@edu.vn', 'www.leloi.edu.vn', 1978, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS003', 'THCS Trần Hưng Đạo', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a402fdd240681152440, 24, 800, '0292.3820000', 'tranhungdao@edu.vn', 'www.tranhungdao.edu.vn', 1982, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS004', 'THCS Bình Thủy', 'THCS', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a406666666666262440, 21, 700, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1985, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS005', 'THCS Cái Răng', 'THCS', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a408fc2f5285c0f2440, 24, 800, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1983, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS006', 'THCS Ô Môn', 'THCS', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a40f6285c8fc2352440, 18, 600, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1987, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS007', 'THCS Thốt Nốt', 'THCS', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a40d7a3703d0a972440, 21, 700, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1986, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS008', 'THCS Phong Điền', 'THCS', 'CL', 'PD', '73 Mậu Thân, Phong Điền, Cần Thơ', 0x0000000001010000003d0ad7a3706d5a405c8fc2f5285c2440, 18, 600, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1988, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS009', 'THCS Cờ Đỏ', 'THCS', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a407b14ae47e13a2440, 18, 600, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1989, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS010', 'THCS Vĩnh Thạnh', 'THCS', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a40a4703d0ad7e32340, 15, 500, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1990, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS011', 'THCS Đoàn Thị Điểm', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a405c8fc2f5281c2440, 21, 700, '0292.3820000', 'doanthidiem@edu.vn', 'www.doanthidiem.edu.vn', 1985, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS012', 'THCS An Hòa', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a4004560e2db21d2440, 18, 600, '0292.3820000', 'anhoa@edu.vn', 'www.anhoa.edu.vn', 1987, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS013', 'THCS Huỳnh Thúc Kháng', 'THCS', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a401f85eb51b81e2440, 18, 600, '0292.3820000', 'huynhthuckhang@edu.vn', 'www.huynhthuckhang.edu.vn', 1989, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS014', 'THCS Đào Sơn Tây', 'THCS', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40295c8fc2f5282440, 18, 600, '0292.3840000', 'daosontay@edu.vn', 'www.daosontay.edu.vn', 1990, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS015', 'THCS Lê Bình', 'THCS', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a4052b81e85eb112440, 18, 600, '0292.3840000', 'lebinh@edu.vn', 'www.lebinh.edu.vn', 1991, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS016', 'THCS Thới Long', 'THCS', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a40b81e85eb51382440, 15, 500, '0292.3840000', 'thoilong@edu.vn', 'www.thoilong.edu.vn', 1992, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS017', 'THCS Trung Kiên', 'THCS', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a405c8fc2f5289c2440, 15, 500, '0292.3840000', 'trungkien@edu.vn', 'www.trungkien.edu.vn', 1993, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS018', 'THCS Thới Đông', 'THCS', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a40c3f5285c8f422440, 15, 500, '0292.3840000', 'thoidong@edu.vn', 'www.thoidong.edu.vn', 1994, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS019', 'THCS Tân Thạnh', 'THCS', 'CL', 'TL', '73 Mậu Thân, Thới Lai, Cần Thơ', 0x000000000101000000c3f5285c8f625a4014ae47e17a142440, 12, 400, '0292.3840000', 'tanthanh@edu.vn', 'www.tanthanh.edu.vn', 1995, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THCS020', 'THCS Vĩnh Bình', 'THCS', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a40ec51b81e85eb2340, 12, 400, '0292.3840000', 'vinhbinh@edu.vn', 'www.vinhbinh.edu.vn', 1996, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT001', 'THPT Chuyên Lý Tự Trọng', 'THPT', 'CV', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a4014ae47e17a142440, 36, 1200, '0292.3820000', 'lytutrong@edu.vn', 'www.lytutrong.edu.vn', 1985, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT002', 'THPT Châu Văn Liêm', 'THPT', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a402fdd240681152440, 42, 1500, '0292.3820000', 'chauvanliem@edu.vn', 'www.chauvanliem.edu.vn', 1975, 18000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT003', 'THPT Nguyễn Việt Hồng', 'THPT', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x000000000101000000e17a14ae47715a40fa7e6abc74132440, 39, 1350, '0292.3820000', 'nguyenvietdong@edu.vn', 'www.nguyenvietdong.edu.vn', 1980, 16000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT004', 'THPT Bùi Hữu Nghĩa', 'THPT', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40a4703d0ad7232440, 36, 1200, '0292.3840000', 'buihuunghia@edu.vn', 'www.buihuunghia.edu.vn', 1982, 14000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT005', 'THPT Thốt Nốt', 'THPT', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a4014ae47e17a942440, 33, 1100, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1990, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT006', 'THPT Phan Ngọc Tòng', 'THPT', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a40cdcccccccc0c2440, 36, 1200, '0292.3840000', 'phanngoctong@edu.vn', 'www.phanngoctong.edu.vn', 1988, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT007', 'THPT Ô Môn', 'THPT', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a403333333333332440, 30, 1000, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1992, 11000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT008', 'THPT Thới Lai', 'THPT', 'CL', 'TL', '73 Mậu Thân, Thới Lai, Cần Thơ', 0x000000000101000000c3f5285c8f625a408fc2f5285c0f2440, 27, 900, '0292.3840000', 'thoilai@edu.vn', 'www.thoilai.edu.vn', 1995, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT009', 'THPT Cờ Đỏ', 'THPT', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a40b81e85eb51382440, 30, 1000, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1993, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT010', 'THPT Vĩnh Thạnh', 'THPT', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a40e17a14ae47e12340, 24, 800, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1996, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT011', 'THPT Thực hành Sư phạm (ĐHCT)', 'THPT', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x00000000010100000052b81e85eb715a409a99999999192440, 30, 1000, '0292.3820000', 'thsp@ctu.edu.vn', 'thsp.ctu.edu.vn', 1990, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT012', 'THPT Lương Định Của', 'THPT', 'CL', 'NK', '73 Mậu Thân, Ninh Kiều, Cần Thơ', 0x0000000001010000009a99999999715a40b4c876be9f1a2440, 27, 900, '0292.3820000', 'luongdinhcua@edu.vn', 'www.luongdinhcua.edu.vn', 1988, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT013', 'THPT Nguyễn Trãi', 'THPT', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a406666666666262440, 33, 1100, '0292.3840000', 'nguyentrai@edu.vn', 'www.nguyentrai.edu.vn', 1985, 13000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT014', 'THPT Hoàng Hoa Thám', 'THPT', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x0000000001010000003333333333735a408fc2f5285c0f2440, 30, 1000, '0292.3840000', 'hoanghoatham@edu.vn', 'www.hoanghoatham.edu.vn', 1987, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT015', 'THPT Lưu Hữu Phước', 'THPT', 'CL', 'OM', '73 Mậu Thân, Ô Môn, Cần Thơ', 0x00000000010100000048e17a14ae675a40f6285c8fc2352440, 27, 900, '0292.3840000', 'luuhuuphuoc@edu.vn', 'www.luuhuuphuoc.edu.vn', 1989, 11000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT016', 'THPT Thuận Hưng', 'THPT', 'CL', 'TN', '73 Mậu Thân, Thốt Nốt, Cần Thơ', 0x000000000101000000713d0ad7a3605a409a99999999992440, 24, 800, '0292.3840000', 'thuanhung@edu.vn', 'www.thuanhung.edu.vn', 1991, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT017', 'THPT Trung An', 'THPT', 'CL', 'CD', '73 Mậu Thân, Cờ Đỏ, Cần Thơ', 0x000000000101000000cdcccccccc5c5a400000000000402440, 24, 800, '0292.3840000', 'trungan@edu.vn', 'www.trungan.edu.vn', 1992, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT018', 'THPT Phong Điền', 'THPT', 'CL', 'PD', '73 Mậu Thân, Phong Điền, Cần Thơ', 0x0000000001010000003d0ad7a3706d5a401f85eb51b85e2440, 21, 700, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1993, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT019', 'THPT Thạnh An', 'THPT', 'CL', 'VT', '73 Mậu Thân, Vĩnh Thạnh, Cần Thơ', 0x000000000101000000f6285c8fc2655a406666666666e62340, 18, 600, '0292.3840000', 'thanhan@edu.vn', 'www.thanhan.edu.vn', 1994, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06'),
('THPT020', 'THPT Định Môn', 'THPT', 'CL', 'TL', '73 Mậu Thân, Thới Lai, Cần Thơ', 0x000000000101000000c3f5285c8f625a4014ae47e17a142440, 18, 600, '0292.3840000', 'dinhmon@edu.vn', 'www.dinhmon.edu.vn', 1995, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-09 03:07:06');

--
-- Bẫy `truong_hoc`
--
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_log_change` AFTER UPDATE ON `truong_hoc` FOR EACH ROW BEGIN
    IF OLD.so_hoc_sinh != NEW.so_hoc_sinh THEN
        INSERT INTO lich_su_thay_doi (ma_truong, loai_thay_doi, noi_dung_thay_doi, nguoi_thay_doi)
        VALUES (NEW.ma_truong, 'Cập nhật số liệu', 
                CONCAT('Cập nhật số học sinh từ ', OLD.so_hoc_sinh, ' lên ', NEW.so_hoc_sinh), 
                'System');
    END IF;
    
    IF OLD.dia_chi != NEW.dia_chi THEN
        INSERT INTO lich_su_thay_doi (ma_truong, loai_thay_doi, noi_dung_thay_doi, nguoi_thay_doi)
        VALUES (NEW.ma_truong, 'Thay đổi địa chỉ', 
                CONCAT('Thay đổi địa chỉ từ "', OLD.dia_chi, '" thành "', NEW.dia_chi, '"'), 
                'System');
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_update` BEFORE UPDATE ON `truong_hoc` FOR EACH ROW BEGIN
    SET NEW.ngay_cap_nhat = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `thong_ke_truong_theo_cap_hoc`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_cap_hoc`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_cap_hoc`  AS SELECT `ch`.`ma_cap_hoc` AS `ma_cap_hoc`, `ch`.`ten_cap_hoc` AS `ten_cap_hoc`, `ch`.`thu_tu` AS `thu_tu`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`cap_hoc` `ch` left join `truong_hoc` `th` on((`ch`.`ma_cap_hoc` = `th`.`ma_cap_hoc`))) GROUP BY `ch`.`ma_cap_hoc`, `ch`.`ten_cap_hoc`, `ch`.`thu_tu` ORDER BY `ch`.`thu_tu` ASC ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `thong_ke_truong_theo_loai`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_loai`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_loai`  AS SELECT `lt`.`ma_loai_truong` AS `ma_loai_truong`, `lt`.`ten_loai_truong` AS `ten_loai_truong`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`loai_truong` `lt` left join `truong_hoc` `th` on((`lt`.`ma_loai_truong` = `th`.`ma_loai_truong`))) GROUP BY `lt`.`ma_loai_truong`, `lt`.`ten_loai_truong` ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `thong_ke_truong_theo_quan_huyen`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_quan_huyen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_quan_huyen`  AS SELECT `qh`.`ma_quan_huyen` AS `ma_quan_huyen`, `qh`.`ten_quan_huyen` AS `ten_quan_huyen`, `qh`.`loai_don_vi` AS `loai_don_vi`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`quan_huyen` `qh` left join `truong_hoc` `th` on((`qh`.`ma_quan_huyen` = `th`.`ma_quan_huyen`))) GROUP BY `qh`.`ma_quan_huyen`, `qh`.`ten_quan_huyen`, `qh`.`loai_don_vi` ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `cap_hoc`
--
ALTER TABLE `cap_hoc`
  ADD PRIMARY KEY (`ma_cap_hoc`),
  ADD UNIQUE KEY `ten_cap_hoc` (`ten_cap_hoc`);

--
-- Chỉ mục cho bảng `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  ADD PRIMARY KEY (`ma_co_so`),
  ADD KEY `idx_co_so_ma_truong` (`ma_truong`),
  ADD KEY `idx_co_so_loai` (`loai_co_so`);

--
-- Chỉ mục cho bảng `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  ADD PRIMARY KEY (`ma_lich_su`),
  ADD KEY `idx_lich_su_ma_truong` (`ma_truong`),
  ADD KEY `idx_lich_su_ngay_thay_doi` (`ngay_thay_doi`);

--
-- Chỉ mục cho bảng `loai_truong`
--
ALTER TABLE `loai_truong`
  ADD PRIMARY KEY (`ma_loai_truong`);

--
-- Chỉ mục cho bảng `quan_huyen`
--
ALTER TABLE `quan_huyen`
  ADD PRIMARY KEY (`ma_quan_huyen`);

--
-- Chỉ mục cho bảng `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  ADD PRIMARY KEY (`ma_truong_da_cap`),
  ADD UNIQUE KEY `ma_truong` (`ma_truong`,`ma_cap_hoc`),
  ADD KEY `ma_cap_hoc` (`ma_cap_hoc`);

--
-- Chỉ mục cho bảng `truong_hoc`
--
ALTER TABLE `truong_hoc`
  ADD PRIMARY KEY (`ma_truong`),
  ADD KEY `idx_truong_hoc_cap_hoc` (`ma_cap_hoc`),
  ADD KEY `idx_truong_hoc_quan_huyen` (`ma_quan_huyen`),
  ADD KEY `idx_truong_hoc_loai_truong` (`ma_loai_truong`),
  ADD KEY `idx_truong_hoc_so_hoc_sinh` (`so_hoc_sinh`),
  ADD KEY `idx_truong_hoc_trang_thai` (`trang_thai`),
  ADD KEY `idx_truong_cap_hoc` (`ma_cap_hoc`),
  ADD KEY `idx_truong_loai` (`ma_loai_truong`),
  ADD KEY `idx_truong_quan_huyen` (`ma_quan_huyen`),
  ADD KEY `idx_truong_trang_thai` (`trang_thai`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  MODIFY `ma_co_so` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  MODIFY `ma_lich_su` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  MODIFY `ma_truong_da_cap` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  ADD CONSTRAINT `co_so_vat_chat_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`);

--
-- Các ràng buộc cho bảng `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  ADD CONSTRAINT `lich_su_thay_doi_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`);

--
-- Các ràng buộc cho bảng `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  ADD CONSTRAINT `truong_da_cap_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`),
  ADD CONSTRAINT `truong_da_cap_ibfk_2` FOREIGN KEY (`ma_cap_hoc`) REFERENCES `cap_hoc` (`ma_cap_hoc`);

--
-- Các ràng buộc cho bảng `truong_hoc`
--
ALTER TABLE `truong_hoc`
  ADD CONSTRAINT `truong_hoc_ibfk_1` FOREIGN KEY (`ma_cap_hoc`) REFERENCES `cap_hoc` (`ma_cap_hoc`),
  ADD CONSTRAINT `truong_hoc_ibfk_2` FOREIGN KEY (`ma_loai_truong`) REFERENCES `loai_truong` (`ma_loai_truong`),
  ADD CONSTRAINT `truong_hoc_ibfk_3` FOREIGN KEY (`ma_quan_huyen`) REFERENCES `quan_huyen` (`ma_quan_huyen`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
