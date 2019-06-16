// Add constraints on business
CREATE CONSTRAINT ON (b:Business) ASSERT
b.id IS UNIQUE


// Populate business
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_business.csv" 
AS row
CREATE (:Business {id: row.business_id, name:row.name, postal_code:row.postal_code,

		latitude:row.latitude, longitude:row.longitude, stars:row.stars, 
		review_count:row.review_count, is_open:row.is_open})


// Add constraints on city and states
CREATE CONSTRAINT ON (c:City) ASSERT
c.name IS UNIQUE
CREATE CONSTRAINT ON (s:State) ASSERT
s.name IS UNIQUE


// Create City and States
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_business_city.csv" AS row
MERGE (c:City {name: row.city})
MERGE (s:State {name: row.state})
MERGE(c)-[:IN_AREA]->(s)


// Create business and city relations
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_business.csv" AS row
MATCH(b:Business {id: row.business_id})
MATCH(c:City {name: row.city})
MERGE(b)-[:IN_CITY]->(c)


// Create index
CREATE CONSTRAINT ON (c:Category) ASSERT
c.name IS UNIQUE

// Create categories
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_business_categories.csv" AS row
MATCH(b:Business {id:row.business_id})
MERGE(c:Category {name: row.category})
MERGE(b)-[:IN_CATEGORY]->(c)



// Create constraint on user_id
CREATE CONSTRAINT ON (u:User) ASSERT u.user_id IS UNIQUE

// Create Users
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_user.csv" AS row
MERGE(u:User {user_id: row.user_id, name:row.name,review_count: row.review_count,yelping_since: row.yelping_since
,useful: row.useful,funny: row.funny,cool: row.cool,fans: row.fans,average_stars: row.average_stars,
compliment_hot: row.compliment_hot,compliment_more:row.compliment_more,compliment_profile:row.compliment_profile,
compliment_cute: row.compliment_cute,compliment_list: row.compliment_list,compliment_note: row.compliment_note,compliment_plain: row.compliment_plain,compliment_cool: row.compliment_cool,compliment_funny:row.compliment_funny,compliment_writer: row.compliment_writer,compliment_photos:
row.compliment_photos})

// Create Friendships
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_user_friendship.csv" AS row
MATCH(u1:User {user_id: row.user1})
MATCH(u2:User {user_id: row.user2})
MERGE (u1)-[:FRIENDS]->(u2)

// Create constraint on review
CREATE CONSTRAINT ON (r:Review) ASSERT r.review_id IS UNIQUE

// Create Reviews
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_review.csv" AS row
CREATE(r:Review {review_id: row.review_id, stars: row.stars, useful: row.useful, funny: row.funny,
		cool: row.cool, date: row.date})
 this article aims to summarise the design trade-offs involved, and give details on some of the prospects for improvement that are being investigated.

// Link reviews
USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "file:///yelp_academic_dataset_review.csv" AS row
MATCH(r:Review {review_id: row.review_id})
MATCH(b:Business {id: row.business_id})
MATCH(u:User {user_id: row.user_id})
MERGE(u)-[:WROTE]->(r)
MERGE(r)-[:REVIEWS]->(b)