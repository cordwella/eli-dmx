PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;
CREATE TABLE "categories" (
  "id" int(11) NOT NULL ,
  "category" varchar(20) NOT NULL,
  PRIMARY KEY ("id")
);
INSERT INTO "categories" VALUES (1,'General');

CREATE TABLE "channels" (
  "cid" int(11) NOT NULL,
  "cname" varchar(25) NOT NULL,
  "cnumber" smallint(6) NOT NULL, 
  "chancategoryid" int(11) DEFAULT NULL,
  PRIMARY KEY ("cid")
  FOREIGN KEY ("chancategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);
INSERT INTO "channels" VALUES (1,'Big Left',1,1);
INSERT INTO "channels" VALUES (2,'Big Right',2,NULL);

CREATE TABLE "scenes" (
  "sid" int(11) NOT NULL, -- 'scene id db identifier',
  "sname" varchar(25) NOT NULL,--  'human readable scene name',
  "scenecategoryid" int(11) DEFAULT NULL,
  PRIMARY KEY ("sid")
  FOREIGN KEY ("scenecategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);
INSERT INTO "scenes" VALUES (1,'General Wash',1);
INSERT INTO "scenes" VALUES (2,'Stage Lights',NULL);


CREATE TABLE "scene_channels" (
  "id" int(11) NOT NULL ,
  "sceneid" int(11) NOT NULL, --  'fk scenes sid',
  "channelid" int(11) NOT NULL, --  'fk channels cid',
  "percent" decimal(3,0) DEFAULT NULL, -- '100 is full 0 is off null means does not apply',
  PRIMARY KEY ("id"),
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
  FOREIGN KEY ("stackcategoryid") REFERENCES "categories" ("id") ON DELETE SET NULL ON UPDATE SET NULL
);


CREATE TABLE "stack_scenes" (
  "id" int(11) NOT NULL ,
  "stackid" int(11) NOT NULL,
  "sceneid" int(11) NOT NULL,
  "beats" int(5) NOT NULL, -- 'how many beats the scene should last for in the stack',
  "stackorder" int(11) NOT NULL, --'what position in the stack should it occur in',
  "percent" decimal(3,0) NOT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("sceneid") REFERENCES "scenes" ("sid") ON DELETE CASCADE,
  FOREIGN KEY ("stackid") REFERENCES "stacks" ("stid") ON DELETE CASCADE
);

INSERT INTO "stacks" VALUES (1,'Red and Blue',1);

INSERT INTO "stack_scenes" VALUES (1,1,1,5,0,100);
INSERT INTO "stack_scenes" VALUES (3,1,2,5,2,100);

CREATE INDEX "channels_cname" ON "channels" ("cname","cnumber");
CREATE INDEX "channels_chancategoryid" ON "channels" ("chancategoryid");
CREATE INDEX "scenes_sname" ON "scenes" ("sname");
CREATE INDEX "scenes_scenecategoryid" ON "scenes" ("scenecategoryid");
CREATE INDEX "scene_channels_one_chan_ver_in_sce" ON "scene_channels" ("sceneid","channelid");
CREATE INDEX "scene_channels_sceneid" ON "scene_channels" ("sceneid","channelid");
CREATE INDEX "scene_channels_channelid" ON "scene_channels" ("channelid");
CREATE INDEX "stacks_stackchannelid" ON "stacks" ("stackcategoryid");
CREATE INDEX "stack_scenes_one_at_a_time" ON "stack_scenes" ("stackid","stackorder");
CREATE INDEX "stack_scenes_stackid" ON "stack_scenes" ("stackid");
CREATE INDEX "stack_scenes_sceneid" ON "stack_scenes" ("sceneid");

-- View Creation

CREATE VIEW `scene_channels_full` AS select `scene_channels`.`id` AS `id`,`scene_channels`.`sceneid` AS `sceneid`,`scene_channels`.`channelid` AS `channelid`,`scene_channels`.`percent` AS `percent`,`channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid` from (`scene_channels` left join `channels` on((`channels`.`cid` = `scene_channels`.`channelid`)));

CREATE VIEW `scene_with_category` AS select `scenes`.`sid` AS `sid`,`scenes`.`sname` AS `sname`,`scenes`.`scenecategoryid` AS `scenecategoryid`,`categories`.`category` AS `category` from (`scenes` left join `categories` on((`scenes`.`scenecategoryid` = `categories`.`id`)));

CREATE VIEW `stack_scenes_order` AS select `stack_scenes`.`id` AS `id`,`stack_scenes`.`stackid` AS `stackid`,`stack_scenes`.`sceneid` AS `sceneid`,`stack_scenes`.`beats` AS `beats`,`stack_scenes`.`stackorder` AS `stackorder`,`stack_scenes`.`percent` AS `percent` from `stack_scenes` order by `stack_scenes`.`stackorder`;

CREATE VIEW `stack_with_category` AS select `stacks`.`stid` AS `stid`,`stacks`.`stname` AS `stname`,`stacks`.`stackcategoryid` AS `stackcategoryid`,`categories`.`category` AS `category` from (`stacks` left join `categories` on((`stacks`.`stackcategoryid` = `categories`.`id`)));

CREATE VIEW `channel_with_category` AS select `channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid`,`categories`.`category` AS `category` from (`channels` left join `categories` on((`channels`.`chancategoryid` = `categories`.`id`)));
END TRANSACTION;
