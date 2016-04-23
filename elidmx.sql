PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;
CREATE TABLE "categories" (
  "id" int(11) NOT NULL,
  "category" varchar(20) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT cat_uni UNIQUE ("category")
);
INSERT INTO "categories" VALUES (1,'General');

CREATE TABLE "channels" (
  "cid" int(11) NOT NULL,
  "cname" varchar(25) NOT NULL,
  "cnumber" smallint(6) NOT NULL,
  "chancategoryid" int(11) DEFAULT NULL,
  PRIMARY KEY ("cid"),
  CONSTRAINT cnum_uni UNIQUE ("cnumber"),
  CONSTRAINT cname_uni UNIQUE ("cname"),
  FOREIGN KEY ("chancategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);
INSERT INTO "channels" VALUES (1,'Big Left',1,1);
INSERT INTO "channels" VALUES (2,'Big Right',2,NULL);

CREATE TABLE "scenes" (
  "sid" int(11) NOT NULL, -- 'scene id db identifier',
  "sname" varchar(25) NOT NULL,--  'human readable scene name',
  "scenecategoryid" int(11) DEFAULT NULL,
  PRIMARY KEY ("sid"),
  CONSTRAINT sname_uni UNIQUE ("sname"),
  FOREIGN KEY ("scenecategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);
INSERT INTO "scenes" VALUES (1,'General Wash',1);
INSERT INTO "scenes" VALUES (2,'Stage Lights',NULL);


CREATE TABLE "scene_channels" (
  "id" int(11) NOT NULL,
  "sceneid" int(11) NOT NULL, --  'fk scenes sid',
  "channelid" int(11) NOT NULL, --  'fk channels cid',
  "percent" decimal(3,0) DEFAULT NULL, -- '100 is full 0 is off null means does not apply',
  PRIMARY KEY ("id"),
  CONSTRAINT scene_channel_uni UNIQUE ("sceneid","channelid"),
  FOREIGN KEY ("channelid") REFERENCES "channels" ("cid") ON DELETE CASCADE,
  FOREIGN KEY ("sceneid") REFERENCES "scenes" ("sid") ON DELETE CASCADE
);
INSERT INTO "scene_channels" VALUES (1,1,1,100);
INSERT INTO "scene_channels" VALUES (3,2,2,100);



CREATE TABLE "stacks" (
  "stid" int(11) NOT NULL, -- 'stack id',
  "stname" varchar(25) NOT NULL, -- 'stack name',
  "stackcategoryid" int(11) DEFAULT NULL,
  PRIMARY KEY ("stid"),
  CONSTRAINT stname_uni UNIQUE ("stname"),
  FOREIGN KEY ("stackcategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);


CREATE TABLE "stack_scenes" (
  "id" int(11) NOT NULL,
  "stackid" int(11) NOT NULL,
  "sceneid" int(11) NOT NULL,
  "beats" int(5) NOT NULL, -- 'how many beats the scene should last for in the stack',
  "stackorder" int(11) NOT NULL, --'what position in the stack should it occur in',
  "percent" decimal(3,0) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT one_at_a_time_uni UNIQUE ("stackid","stackorder"),
  FOREIGN KEY ("sceneid") REFERENCES "scenes" ("sid") ON DELETE CASCADE,
  FOREIGN KEY ("stackid") REFERENCES "stacks" ("stid") ON DELETE CASCADE
);

INSERT INTO "stacks" VALUES (1,'Red and Blue',1);

INSERT INTO "stack_scenes" VALUES (1,1,1,5,0,100);
INSERT INTO "stack_scenes" VALUES (3,1,2,5,2,100);

-- View Creation

CREATE VIEW `scene_channels_full` AS select `scene_channels`.`id` AS `id`,`scene_channels`.`sceneid` AS `sceneid`,`scene_channels`.`channelid` AS `channelid`,`scene_channels`.`percent` AS `percent`,`channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid` from (`scene_channels` left join `channels` on((`channels`.`cid` = `scene_channels`.`channelid`)));

CREATE VIEW `scene_with_category` AS select `scenes`.`sid` AS `sid`,`scenes`.`sname` AS `sname`,`scenes`.`scenecategoryid` AS `scenecategoryid`,`categories`.`category` AS `category` from (`scenes` left join `categories` on((`scenes`.`scenecategoryid` = `categories`.`id`)));

CREATE VIEW `stack_scenes_order` AS select `stack_scenes`.`id` AS `id`,`stack_scenes`.`stackid` AS `stackid`,`stack_scenes`.`sceneid` AS `sceneid`,`stack_scenes`.`beats` AS `beats`,`stack_scenes`.`stackorder` AS `stackorder`,`stack_scenes`.`percent` AS `percent` from `stack_scenes` order by `stack_scenes`.`stackorder`;

CREATE VIEW `stack_with_category` AS select `stacks`.`stid` AS `stid`,`stacks`.`stname` AS `stname`,`stacks`.`stackcategoryid` AS `stackcategoryid`,`categories`.`category` AS `category` from (`stacks` left join `categories` on((`stacks`.`stackcategoryid` = `categories`.`id`)));

CREATE VIEW `channel_with_category` AS select `channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid`,`categories`.`category` AS `category` from (`channels` left join `categories`  on((`channels`.`chancategoryid` = `categories`.`id`)));

-- Table for various pieces of info (IE BPM & fadetime)

CREATE TABLE "settings"(
    "id" int(11) NOT NULL,
    "name" varchar(10) NOT NULL,
    "value" int(11) NOT NULL,
    PRIMARY KEY ("id"),
    CONSTRAINT set_name UNIQUE ("name")
);

INSERT INTO "settings" VALUES (1,'bpm',60);
INSERT INTO "settings" VALUES (2,'fadetime',0);

END TRANSACTION;
