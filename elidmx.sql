-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 18, 2016 at 02:26 AM
-- Server version: 5.6.21
-- PHP Version: 5.6.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `elidmx`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
`id` int(11) NOT NULL,
  `category` varchar(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `category`) VALUES
(1, 'General');

-- --------------------------------------------------------

--
-- Table structure for table `channels`
--

CREATE TABLE IF NOT EXISTS `channels` (
`cid` int(11) NOT NULL COMMENT 'channel id, very important as this will be what ties it to everything else (channels are the lowest thing, think an atom)',
  `cname` varchar(25) NOT NULL COMMENT 'human readable name',
  `cnumber` smallint(6) NOT NULL COMMENT 'channel number as in the one sent with the DMX cable (should match up to dimmer pack) does not allow null, if you are moving channels around it is advised you place them into an unused channel number ',
  `chancategoryid` int(11) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `channels`
--

INSERT INTO `channels` (`cid`, `cname`, `cnumber`, `chancategoryid`) VALUES
(1, 'Big Left', 1, 1),
(2, 'Big Right', 2, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `channel_with_category`
--
CREATE TABLE IF NOT EXISTS `channel_with_category` (
`cid` int(11)
,`cname` varchar(25)
,`cnumber` smallint(6)
,`chancategoryid` int(11)
,`category` varchar(20)
);
-- --------------------------------------------------------

--
-- Table structure for table `scenes`
--

CREATE TABLE IF NOT EXISTS `scenes` (
`sid` int(11) NOT NULL COMMENT 'scene id db identifier',
  `sname` varchar(25) NOT NULL COMMENT 'human readable scene name',
  `scenecategoryid` int(11) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='Sets up scene definitions, channel data in scene_channels table';

--
-- Dumping data for table `scenes`
--

INSERT INTO `scenes` (`sid`, `sname`, `scenecategoryid`) VALUES
(1, 'General Wash', 1),
(2, 'Stage Lights', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `scene_channels`
--

CREATE TABLE IF NOT EXISTS `scene_channels` (
`id` int(11) NOT NULL,
  `sceneid` int(11) NOT NULL COMMENT 'fk scenes sid',
  `channelid` int(11) NOT NULL COMMENT 'fk channels cid',
  `percent` decimal(3,0) DEFAULT NULL COMMENT '100 is full 0 is off null means does not apply'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='how channels relate to each scene';

-- --------------------------------------------------------

--
-- Stand-in structure for view `scene_with_category`
--
CREATE TABLE IF NOT EXISTS `scene_with_category` (
`sid` int(11)
,`sname` varchar(25)
,`scenecategoryid` int(11)
,`category` varchar(20)
);
-- --------------------------------------------------------

--
-- Table structure for table `stacks`
--

CREATE TABLE IF NOT EXISTS `stacks` (
`stid` int(11) NOT NULL COMMENT 'stack id',
  `stname` varchar(25) NOT NULL COMMENT 'stack name',
  `stackcategoryid` int(11) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stacks`
--

INSERT INTO `stacks` (`stid`, `stname`, `stackcategoryid`) VALUES
(1, 'Red and Blue', 1);

-- --------------------------------------------------------

--
-- Table structure for table `stack_channels`
--

CREATE TABLE IF NOT EXISTS `stack_channels` (
`id` int(11) NOT NULL,
  `stackid` int(11) NOT NULL,
  `sceneid` int(11) NOT NULL,
  `beats` float NOT NULL COMMENT 'how many beats the scene should last for in the stack',
  `stackorder` int(11) NOT NULL COMMENT 'what position in the stack should it occur in',
  `percent` decimal(3,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Stand-in structure for view `stack_with_category`
--
CREATE TABLE IF NOT EXISTS `stack_with_category` (
`stid` int(11)
,`stname` varchar(25)
,`stackcategoryid` int(11)
,`category` varchar(20)
);
-- --------------------------------------------------------

--
-- Structure for view `channel_with_category`
--
DROP TABLE IF EXISTS `channel_with_category`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `channel_with_category` AS select `channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid`,`categories`.`category` AS `category` from (`channels` left join `categories` on((`channels`.`chancategoryid` = `categories`.`id`)));

-- --------------------------------------------------------

--
-- Structure for view `scene_with_category`
--
DROP TABLE IF EXISTS `scene_with_category`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `scene_with_category` AS select `scenes`.`sid` AS `sid`,`scenes`.`sname` AS `sname`,`scenes`.`scenecategoryid` AS `scenecategoryid`,`categories`.`category` AS `category` from (`scenes` left join `categories` on((`scenes`.`scenecategoryid` = `categories`.`id`)));

-- --------------------------------------------------------

--
-- Structure for view `stack_with_category`
--
DROP TABLE IF EXISTS `stack_with_category`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `stack_with_category` AS select `stacks`.`stid` AS `stid`,`stacks`.`stname` AS `stname`,`stacks`.`stackcategoryid` AS `stackcategoryid`,`categories`.`category` AS `category` from (`stacks` left join `categories` on((`stacks`.`stackcategoryid` = `categories`.`id`)));

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `channels`
--
ALTER TABLE `channels`
 ADD PRIMARY KEY (`cid`), ADD UNIQUE KEY `cname` (`cname`,`cnumber`), ADD KEY `chancategoryid` (`chancategoryid`);

--
-- Indexes for table `scenes`
--
ALTER TABLE `scenes`
 ADD PRIMARY KEY (`sid`), ADD UNIQUE KEY `sname` (`sname`), ADD KEY `scenecategoryid` (`scenecategoryid`);

--
-- Indexes for table `scene_channels`
--
ALTER TABLE `scene_channels`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `one_chan_ver_in_sce` (`sceneid`,`channelid`), ADD KEY `sceneid` (`sceneid`,`channelid`), ADD KEY `channelid` (`channelid`);

--
-- Indexes for table `stacks`
--
ALTER TABLE `stacks`
 ADD PRIMARY KEY (`stid`), ADD KEY `stackchannelid` (`stackcategoryid`);

--
-- Indexes for table `stack_channels`
--
ALTER TABLE `stack_channels`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `one_at_a_time` (`stackid`,`stackorder`), ADD KEY `stackid` (`stackid`), ADD KEY `sceneid` (`sceneid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `channels`
--
ALTER TABLE `channels`
MODIFY `cid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'channel id, very important as this will be what ties it to everything else (channels are the lowest thing, think an atom)',AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `scenes`
--
ALTER TABLE `scenes`
MODIFY `sid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'scene id db identifier',AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `scene_channels`
--
ALTER TABLE `scene_channels`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `stacks`
--
ALTER TABLE `stacks`
MODIFY `stid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'stack id',AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `stack_channels`
--
ALTER TABLE `stack_channels`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `channels`
--
ALTER TABLE `channels`
ADD CONSTRAINT `channels_ibfk_1` FOREIGN KEY (`chancategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `scenes`
--
ALTER TABLE `scenes`
ADD CONSTRAINT `scene_cat_fk` FOREIGN KEY (`scenecategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `scene_channels`
--
ALTER TABLE `scene_channels`
ADD CONSTRAINT `channelid_fk` FOREIGN KEY (`channelid`) REFERENCES `channels` (`cid`) ON DELETE CASCADE,
ADD CONSTRAINT `sceneid_fk` FOREIGN KEY (`sceneid`) REFERENCES `scenes` (`sid`) ON DELETE CASCADE;

--
-- Constraints for table `stacks`
--
ALTER TABLE `stacks`
ADD CONSTRAINT `stack_cat_fk` FOREIGN KEY (`stackcategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `stack_channels`
--
ALTER TABLE `stack_channels`
ADD CONSTRAINT `scene_stack_fk` FOREIGN KEY (`sceneid`) REFERENCES `scenes` (`sid`) ON DELETE CASCADE,
ADD CONSTRAINT `stack_fk` FOREIGN KEY (`stackid`) REFERENCES `stacks` (`stid`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
