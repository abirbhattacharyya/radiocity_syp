-- phpMyAdmin SQL Dump
-- version 3.3.7deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 10, 2012 at 02:30 PM
-- Server version: 5.1.49
-- PHP Version: 5.3.3-1ubuntu9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `radio_city_syp`
--

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `user_id`, `name`, `description`, `regular_price`, `target_price`, `quantity`, `product_type`, `is_live`, `created_at`, `updated_at`, `image_file_name`, `image_content_type`, `image_file_size`, `image_updated_at`) VALUES
(1, 1, 'Premium Peak Ticket', 'Premium Peak Ticket', 150, 128, NULL, 1, 1, '2012-07-09 07:30:57', '2012-07-09 07:30:57', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 07:30:57'),
(2, 1, 'Premium Peak Ticket', 'Premium Peak Ticket', 200, 170, NULL, 1, 1, '2012-07-09 07:44:04', '2012-07-09 07:44:04', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 07:44:04'),
(3, 1, 'Premium Peak Ticket', 'Premium Peak Ticket', 250, 213, NULL, 1, 1, '2012-07-09 08:46:45', '2012-07-09 08:46:45', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:46:45'),
(4, 1, 'Premium Non-Peak Ticket', 'Premium Non-Peak Ticket', 130, 111, NULL, 1, 1, '2012-07-09 08:48:02', '2012-07-09 08:48:02', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:48:02'),
(5, 1, 'Orchestra Peak Ticket', 'Orchestra Peak Ticket', 115, 98, NULL, 1, 1, '2012-07-09 08:49:09', '2012-07-09 08:49:09', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:49:09'),
(6, 1, 'Orchestra Non-Peak Ticket', 'Orchestra Non-Peak Ticket', 90, 77, NULL, 1, 1, '2012-07-09 08:49:50', '2012-07-09 08:49:50', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:49:50'),
(7, 1, 'Second Mezz Peak Ticket', 'Second Mezz Peak Ticket', 79, 68, NULL, 1, 1, '2012-07-09 08:50:29', '2012-07-09 08:50:29', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:50:29'),
(8, 1, 'Second Mezz Non-Peak Ticket', 'Second Mezz Non-Peak Ticket', 59, 51, NULL, 1, 1, '2012-07-09 08:51:32', '2012-07-09 08:51:32', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-09 08:51:32'),
(9, 1, 'Tickets & Memories', '2 Tickets + Commemorative Souvenir', 350, 298, NULL, 2, 1, '2012-07-10 07:02:09', '2012-07-10 07:02:09', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-10 07:02:09'),
(10, 1, 'Tickets + Food', '2 Tickets + 2 Popcorns', 374, 318, NULL, 2, 1, '2012-07-10 07:03:10', '2012-07-10 07:24:19', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-10 07:24:19'),
(11, 1, 'Family Spectacular', '4 Tickets+4 Souvenirs+4 Popcorns+4 Sodas', 880, 748, NULL, 2, 1, '2012-07-10 07:04:30', '2012-07-10 07:04:30', 'P1276_Austin_RadioCity_405x270.jpg', 'image/jpeg', 21026, '2012-07-10 07:04:30');
