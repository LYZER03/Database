//
// Database: company.js
// 
// Write the MongoDB queries that return the information below:
//

// all the employees
db.employees.find({});

// the number of employees
db.employees.countDocuments({});

// one of the employees, with pretty printing (2 methods)
// method 1
db.employees.findOne({});
// method 2
db.employees.find({}).limit(1).pretty();

// --

// all the information about employees, except their salary, commission and missions
db.employees.find({}, { salary: 0, commission: 0, missions: 0 }).pretty();

// the name and salary of all the employees (without the field _id)
db.employees.find({}, { _id: 0, name: 1, salary: 1 }).pretty();

// the name, salary and first mission (if any) of all the employees (without the field _id)
db.employees.aggregate([
    {
      $project: {
        _id: 0,
        name: 1,
        salary: 1,
        firstMission: { $arrayElemAt: ["$missions", 0] }
      }
    }
  ]).pretty();

// --

// the name and salary of the employees with a salary in the range [1,000; 2,500[
db.employees.aggregate([
    {
        $match: {
        salary: {
            $gte: 1000,
            $lt: 2500
        }
        }
    },
    {
        $project: {
        _id: 0,
        name: 1,
        salary: 1
        }
    }
    ]).pretty();

// the name and salary of the clerks with a salary in the range [1,000; 1,500[ (2 methods)
// Method 1: Using the `find()` method with query filters
db.employees.find({
    job: "clerk",
    salary: {
      $gte: 1000,
      $lt: 1500
    }
  }, { _id: 0, name: 1, salary: 1 }).pretty();
// Method 2: Using the `aggregate()` method
db.employees.aggregate([
    {
      $match: {
        job: "clerk",
        salary: {
          $gte: 1000,
          $lt: 1500
        }
      }
    },
    {
      $project: {
        _id: 0,
        name: 1,
        salary: 1
      }
    }
  ]).pretty();

// the employees whose manager is 7839 or whose salary is less than 1000
db.employees.aggregate([
    {
      $match: {
        $or: [
          { manager: 7839 },
          { salary: { $lt: 1000 } }
        ]
      }
    }
  ]).pretty();

// the clerks and the analysts (2 methods)
// Method 1: Using the $in operator with the find() method
db.employees.find({
    job: { $in: ["clerk", "analyst"] }
  }).pretty();
// Method 2: Using the $match stage with the aggregate() method
db.employees.aggregate([
    {
      $match: {
        job: { $in: ["clerk", "analyst"] }
      }
    }
  ]).pretty();

// --

// the name, job and salary of the employees, sorted first by job (ascending) and then by salary (descending)
db.employees.aggregate([
    {
      $project: {
        _id: 0,
        name: 1,
        job: 1,
        salary: 1
      }
    },
    {
      $sort: {
        job: 1,  // Sort by job in ascending order
        salary: -1 // Then sort by salary in descending order
      }
    }
  ]).pretty();

// one of the employees with the highest salary
db.employees.aggregate([
    {
      $sort: {
        salary: -1 // Sort by salary in descending order
      }
    },
    {
      $limit: 1 // Limit the result to one document
    }
  ]).pretty();
// --

// the employee names that begin with 'S' and end with 't' (2 methods)
// Method 1: Using the find() method with regular expressions
db.employees.find({
    name: /^S.*t$/
  }, { _id: 0, name: 1 }).pretty();

// Method 2: Using the $regex operator with the find() method
db.employees.find({
    name: {
      $regex: /^S.*t$/
    }
  }, { _id: 0, name: 1 }).pretty();
  
// the employee names that contain a double 'l'
db.employees.find({
name: { $regex: /.*ll.*/ }
}, { _id: 0, name: 1 }).pretty();

// the employee names that begins with 'S' and contains either 'o' or 'm' (2 methods)
// Method 1: Using regular expressions with the find() method
db.employees.find({
    name: /^S.*[om].*$/
  }, { _id: 0, name: 1 }).pretty();
// Method 2: Using the $or operator with the find() method
db.employees.find({
    $and: [
      { name: /^S/ }, // Begins with 'S'
      { $or: [
        { name: /o/ }, // Contains 'o'
        { name: /m/ } // Contains 'm'
      ]}
    ]
  }, { _id: 0, name: 1 }).pretty();
  
// --

// the name and the commission of the employees whose commission is not specified
// (the field "commission" does not exists or it has a null value)
db.employees.find({
    $or: [
      { commission: { $exists: false } },
      { commission: null }
    ]
  }, { _id: 0, name: 1, commission: 1 }).pretty();

// the name and the commission of the employees whose commission is specified
// (the field "commission" does exist and it has a non-null value)
db.employees.find({
    commission: { $exists: true, $ne: null }
  }, { _id: 0, name: 1, commission: 1 }).pretty();

// the name and the commission of the employees with a field "commission"
// (regardless of its value)
db.employees.find({
    commission: { $exists: true }
  }, { _id: 0, name: 1, commission: 1 }).pretty();

// the name and the commission of the employees whose commission is null
// (the field "commission" does exist but it has a null value)
db.employees.find({
    commission: null
  }, { _id: 0, name: 1, commission: 1 }).pretty()

// --

// the employees who work in Dallas
db.employees.find({
    "department.location": "Dallas"
  }, { _id: 0 }).pretty();

// the employees who don't work in Chicago (2 methods)
// Method 1: Find employees who don't work in Chicago using $ne
db.employees.find({
    "department.location": { $ne: "Chicago" }
  }, { _id: 0 }).pretty();
// Method 2: Find employees who don't work in Chicago using $nin
db.employees.find({
    "department.location": { $nin: ["Chicago"] }
  }, { _id: 0 }).pretty();

// the employees who did a mission in Chicago
db.employees.find({
    "missions.location": "Chicago"
  }, { _id: 0 }).pretty();

// the employees who did a mission in Chicago or Dallas  (2 methods)
// Method 1: Find employees who did a mission in Chicago or Dallas using $in
db.employees.find({
    "missions.location": { $in: ["Chicago", "Dallas"] }
  }, { _id: 0 }).pretty();
// Method 2: Find employees who did a mission in Chicago or Dallas using $or
db.employees.find({
    $or: [
      { "missions.location": "Chicago" },
      { "missions.location": "Dallas" }
    ]
  }, { _id: 0 }).pretty();
  
// the employees who did a mission in Lyon and Paris (2 methods)
// Method 1: Find employees who did missions in both Lyon and Paris using $all
db.employees.find({
    "missions.location": {
      $all: ["Lyon", "Paris"]
    }
  }, { _id: 0 }).pretty();
// Method 2: Find employees who did missions in both Lyon and Paris using $and
db.employees.find({
    $and: [
      { "missions.location": "Lyon" },
      { "missions.location": "Paris" }
    ]
  }, { _id: 0 }).pretty();

// the employees who did all their missions in Chicago
db.employees.find({
    $nor: [
      { "missions.location": { $nin: ["Chicago"] } }
    ]
  }, { _id: 0 }).pretty();

// the employees who did a mission for IBM in Chicago
db.employees.find({
  $and: [
    { "missions.location": "Chicago" },
    { "missions.company": "IBM" }
  ]
}, { _id: 0 }).pretty();

// the employees who did their first mission for IBM
db.employees.find({
    "missions": {
      $elemMatch: {
        "company": "IBM"
      }
    }
  }, { _id: 0 }).pretty();

// the employees who did exactly two missions
db.employees.find({
  $where: "this.missions && this.missions.length === 2"
}, { _id: 0 }).pretty();

// --

// the jobs in the company
db.employees.distinct("job");

// the name of the departments
db.employees.distinct("department.name");

// the cities in which the missions took place
db.employees.distinct("missions.location");

// --

// the employees with the same job as Jones
db.employees.aggregate([
    { $match: { name: "Jones" } },
    { $lookup: {
      from: "employees",
      localField: "job",
      foreignField: "job",
      as: "employeesWithSameJob"
    } },
    { $unwind: "$employeesWithSameJob" },
    { $match: { "employeesWithSameJob.name": { $ne: "Jones" } } },
    { $project: { _id: 0, name: "$employeesWithSameJob.name", job: "$employeesWithSameJob.job" } }
  ]);








