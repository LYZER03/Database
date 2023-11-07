//
// Database: company.js
//
// Write the MongoDB queries that return the information below. Find as many solutions as possible for each query.
//

print("Query 01")
// the highest salary of clerks
// Solution 1 using "$match" , "$sort" and "$limit"
db.employees.aggregate([
    {$match: { job:"clerk"}},
    {$sort: {salary:-1}},
    {$limit: 1}
]);
// Solution 2 using "$match" and "$group"
db.employees.aggregate([
    { $match: { job: "clerk" } },
    { $group: { _id: "$job", maxSalary: { $max: "$salary" } } },
]);
  
print("Query 02")
// the total salary of managers
// Solution 1 using "$match" and "$group"
db.employees.aggregate([
    { $match: { job: "manager" } },
    { $group: { _id: "$job", TotalSalary: { $sum: "$salary" } } },
]);

// Solution 2 using "$match", "$expr", "$group" and "$project"
db.employees.aggregate([
    {
      $match: {
        $expr: { $eq: ["$job", "manager"] }
      }
    },
    {
      $group: {
        _id: "$job",
        totalSalary: { $sum: "$salary" }
      }
    },
    { $project: { _id: 0, totalSalary: 1 } }
]);  

print("Query 03")
// the lowest, average and highest salary of the employees
db.employees.aggregate([
    {
        $group: { 
            _id: null, 
            lowestSalary: {$min:"$salary"}, 
            averageSalary: {$avg:"$salary"}, 
            highestSalary: {$max:"$salary"} 
        }
    },
    {
        $project: {
            _id: 0
        }
    }
]);

print("Query 04")
// the name of the departments
db.employees.aggregate([
    { $unwind: "$department" },  // Unwind the "department" array, if present
    { $group: { _id: "$department.name" } },  // Group by department name
    { $project: { _id: 0, name: "$_id" } }  // Project to exclude the _id field and rename it to "name"
]);
  
print("Query 05")
// for each job: the job and the average salary for that job
db.employees.aggregate([
    { $group: { _id: "$job", averageSalary: { $avg: "$salary" }}},
    { $project: { _id: 0, job: "$_id", averageSalary: 1 }}
]);
  
print("Query 06")
// for each department: its name, the number of employees and the average salary in that department (null departments excluded)
db.employees.aggregate([
    {
        $match: { "department.name": { $ne: null } }
    },
    {
        $group: {
            _id: "$department.name",
            departmentName: { $first: "$department.name" },
            numEmployees: { $sum: 1 },
            totalSalary: { $sum: "$salary" }
        }
    },
    {
        $project: {
            _id: 0,
            departmentName: 1,
            numEmployees: 1,
            averageSalary: { $divide: ["$totalSalary", "$numEmployees"] }
        }
    }
]);

print("Query 07")
// the highest of the per-department average salary (null departments excluded)
db.employees.aggregate([
    {
        $match: { "department.name": { $ne: null } }
    },
    {
        $group: {
            _id: "$department.name",
            maxAverageSalary: { $max: { $avg: "$salary" } }
        }
    }
]);
  
print("Query 08")
// the name of the departments with at least 5 employees (null departments excluded)
db.employees.aggregate([
    {
        $match: { "department.name": { $exists: true, $ne: null } }
    },
    {
        $group: {
            _id: "$department.name",
            count: { $sum: 1 }
        }
    },
    {
        $match: { count: { $gte: 5 } }
    },
    {
        $project: {
            _id: 0,
            department: "$_id"
        }
    }
]);

print("Query 09")
// the cities where at least 2 missions took place
db.employees.aggregate([
    {
        $unwind: "$missions"
    },
    {
        $match: {
            "missions.location": { $exists: true, $ne: null }
        }
    },
    {
        $group: {
            _id: "$missions.location",
            count: { $sum: 1 }
        }
    },
    {
        $match: {
            count: { $gte: 2 }
        }
    },
    {
        $project: {
            _id: 0,
            city: "$_id"
        }
    }
]);
  
print("Query 10")
// the highest salary
// Solution 1 using "$group" , "$project" and "$max"
db.employees.aggregate([
    {
        $group: {
            _id: null,
            maxSalary: { $max: "$salary" }
        }
    },
    {
        $project: {
            _id: 0,
            maxSalary: 1
        }
    }
]);

// Solution 2 using "$sort", "$limit" and "$project"
db.employees.aggregate([
    {
        $sort: {
            salary: -1
        }
    },
    {
        $limit: 1
    },
    {
        $project: { _id:0, maxSalary: "$salary"}
    }
]);
  
print("Query 11")
// the name of _one_ of the employees with the highest 
// Solution 1 using "$sort" , "$limit"  and "$project"
db.employees.aggregate([
    {
        $sort: {
            salary: -1
        }
    },
    {
        $limit: 1
    },
    {
        $project: { 
            _id: 0, 
            name: 1
        }
    },
]);

// Solution 2 using "$group" , "$match" and "$project"
db.employees.aggregate([
    {
      $group: {
        _id: null,
        maxSalary: { $max: "$salary" }
      }
    },
    {
      $match: { salary: { $eq: "$maxSalary" } }
    },
    {
      $project: { _id: 0, name: 1 }
    }
]);

print("Query 12")
// the name of _all_ of the employees with the highest salary
db.employees.aggregate([
    {
        $group: {
            _id: null,
            maxSalary: { $max: "$salary" }
        }
    },
    {
        $match: {
            maxSalary: { $exists: true }
        }
    },
    {
        $lookup: {
            from: "employees",
            localField: "maxSalary",
            foreignField: "salary",
            as: "highestPaidEmployees"
      }
    },
    {
        $unwind: "$highestPaidEmployees"
    },
    {
        $project: {
            _id: 0,
            name: "$highestPaidEmployees.name"
        }
    }
]);
  
print("Query 13")
// the name of the departments with the highest average salary
db.employees.aggregate([
    {
        $group: {
            _id: "$department.name",
            averageSalary: { $avg: "$salary" }
        }
    },
    {
        $sort: { averageSalary: -1 }
    },
    {
        $limit: 1
    },
    {
        $project: {
            _id: 0,
            department: "$_id",
            averageSalary: 1
        }
    }
]);
  
print("Query 14")
// for each city in which a mission took place, its name (output field "city") and the number of missions in that city
db.employees.aggregate([
    {
        $unwind: "$missions"
    },
    {
        $group: {
            _id: "$missions.location",
            city: { $first: "$missions.location" },
            missionCount: { $sum: 1 }
        }
    },
    {
        $project: {
        _id: 0,
        city: 1,
        missionCount: 1
        }
    }
]);
  
print("Query 15")
// the name of the employees who did a mission in the city they work in
db.employees.aggregate([
    {
        $unwind: "$missions"
    },
    {
        $match: {
            $expr: {
            $eq: ["$missions.location", "$department.location"]
            }
        }
    },
    {
        $group: {
            _id: "$_id",
            name: { $first: "$name" }
        }
    },
    {
        $project: {
            _id: 0,
            name: 1
        }
    }
]);
  



