//
// Database: company.js
//
// Perform the operations below using MongoDB's CUD methods.
//

// 1) Insert an empty document and check the ID it was assigned

var result1 = db.employees.insertOne({name: "test",job: "test"})
//By default, MongoDB generates a unique ObjectID identifier that 
//is assigned to the _id field in a new document before writing that document to the database.
var insertedId = result1.insertedId;
print("Inserted document with ID:", insertedId);


// 2) Insert the following documents at once: {name: "Blake"} and {_id: "Smith", name: "Smith"}, 
//    then check of the IDs in the collection (value and type)
db.employees.insertMany(
    [
        {name: "Blake"},
        {_id: "Smith", name: "Smith"}  
    ]
)

// Retrieve and print the IDs from the collection
// The first document _id type is "ObjectID", because we didn't assigned him a ID, 
// so MongoDB will generete a unique idfentifier.
// The second document id type is a "string" because we assigned a string value.
var documents = db.employees.find({}, { _id: 1 }).toArray();
documents.forEach(doc => {
    print("Document ID:", doc._id, "Type:", typeof doc._id);
});


// With the the "ordered" option set to true, insert the following documents at once: 
// {_id: 1, name: "insert1"}, {_id: 2, name: "insert2"}, {_id: 2, name: "insert2"}, {_id: 3, name: "insert3"}
try {
    db.employees.insertMany(
        [
            { _id: 1, name: "insert1" },
            { _id: 2, name: "insert2" },
            { _id: 2, name: "insert2" },  // Duplicate _id, will cause an error
            { _id: 3, name: "insert3" }
        ],
        { ordered: true }
    );
    print("Documents inserted successfully.");
} catch (error) {
    print("Error:", error.message);
}
// With the "ordered" option set to false, insert the following documents at once: 
// {_id: 11, name: "insert11"}, {_id: 12, name: "insert12"}, {_id: 12, name: "insert12"}, {_id: 13, name: "insert13"}
// Insert documents with the "ordered" option set to false
db.employees.insertMany(
    [
        { _id: 11, name: "insert11" },
        { _id: 12, name: "insert12" },
        { _id: 12, name: "insert12" },  // Duplicate _id, will cause an error but won't stop the process
        { _id: 13, name: "insert13" }
    ],
    { ordered: false }
);

print("Documents inserted successfully.");

// Compare the result of the above two insert methods
// Ordered set true:
// If we set the "ordered" option to true when using insertMany, 
// MongoDB will continue processing until an error occurs the remaining documents will be not inserted. 
// This means that it will insert all the valid documents before the error occurs and report errors for the invalid ones.

// Ordered set false :
// If we set the "ordered" option to false when using insertMany, 
// MongoDB will continue processing remaining documents even if an error occurs. 
// This means that it will insert all the valid documents and report errors for the invalid ones.

// Raise the salary of all clerks by $300.00
db.employees.updateMany(
    { job: "clerk" },  // Filter to select clerks
    { $inc: { salary: 300.00 } }  // Increment the salary by $300.00
);
print("Salaries updated successfully.");
db.employees.find({ job: "clerk" }, { _id: 0, name: 1, salary: 1 });

// Remove the employees who don't have a manager
db.employees.deleteMany({ manager: null });

// Move the Accounting department from New-York to Dallas
db.employees.updateMany(
    { "department.name": "Accounting", "department.location": "New-York" },
    { $set: { "department.location": "Dallas" } }
);

// Remove the missions of the employees who work in Dallas
db.employees.updateMany(
    { "department.location": "Dallas" },
    { $unset: { missions: "" } }
);

// Rename the field "location" to "city" for departments
db.employees.updateMany(
    { "department": { $exists: true } }, // Filter to match documents with "location" field
    { $rename: { "department.location": "department.city" } } // Rename field using $rename
);
// Remove all the document from the collection
db.employees.deleteMany({});


