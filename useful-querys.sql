/* Definer for view ... */
select scenes.*, `categories`.`category` from scenes left join categories on scenes.scenecategoryid = categories.id;

select stacks.*, `categories`.`category` from stacks left join categories on stacks.stackcategoryid = categories.id 

select channels.*, `categories`.`category` from channels left join categories on channels.chancategoryid = categories.id 
