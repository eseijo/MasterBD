delete from Posts
where OwnerUserId not in (select u.id from Users u);

delete from Posts
where LastEditorUserId not in (select u.id from Users u);

delete from Posts
where AcceptedAnswerId not in (select p.id from (select id from Posts) p);

delete from Posts
where ParentId not in (select p.id from (select id from Posts) p);

delete from Tags
where WikiPostId not in (select p.id from Posts p);

delete from Tags
where ExcerptPostId not in (select p.id from Posts p);

delete from Comments
where PostId not in (select p.id from Posts p);

delete from Comments
where UserId not in (select u.id from Users u);

delete from Votes
where PostId not in (select p.id from Posts p);

delete from Votes
where UserId not in (select u.id from Users u);
