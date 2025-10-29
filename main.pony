use "collections"
use "time"
use "math"

// Worker actor
actor Worker
  let _id: U64
  let _boss: Boss
  let _env: Env

  fun is_perfect_square(num: U64): Bool =>
    let sqrt_num = ((num).f64().sqrt()).u64()
    (sqrt_num * sqrt_num) == num

  new create(env': Env, id': U64, boss: Boss) =>
    _env = env'
    _boss = boss
    _id = id'

  // Function to calculate sum of squares and report to the boss
  be calculate_sum(start_num: U64, end_num: U64) =>
    var square_sum: U64 = 0
    for i in Range[U64](start_num, end_num) do
      square_sum = square_sum + (i * i)
    end

    if is_perfect_square(square_sum) then
      _boss.found_perfect_square(_id, square_sum, start_num, end_num)
    else
      _boss.report_result(square_sum)  // Report result back to the Boss
    end

// Boss actor
actor Boss
  let id: U64
  let n: U64
  let batch_size: U64
  let _env: Env
  var total_sum: U64 = 0
  var completed_tasks: U64 = 0
  // var found_square: Bool = false  // Flag to stop execution

  new create(env: Env, id': U64, n': U64, batch_size': U64) =>
    _env = env
    id = id'
    n = n'
    batch_size = batch_size'

  // Assign tasks to workers
  be assign_task(step: U64) =>
    for i in Range[U64](1, (n+1), batch_size) do //batch_size = 4
      // if not found_square then  // Only continue if no perfect square found
        let worker = Worker(_env, i, this)
        for j in Range[U64](0, batch_size) do
          worker.calculate_sum(i+j, (i + j) + step)
        end
      //end
    end

  // Receive result from a worker and track completion
  be report_result(worker_sum: U64) =>
    // if not found_square then  // Only process if no perfect square found
      total_sum = total_sum + worker_sum
      completed_tasks = completed_tasks + 1
      if completed_tasks == n then
        _env.out.print("All workers finished. Total sum of squares: " + total_sum.string())
      end
    // end

  // Handle the case when a worker finds a perfect square
  be found_perfect_square(worker_id: U64, square_sum: U64, start_num:U64, end_num:U64) =>
    // if not found_square then
      // found_square = true  // Stop other workers from continuing
      _env.out.print("Worker " + worker_id.string() + " found a perfect square between "+start_num.string()+" and "+(end_num-1).string()+": "+square_sum.string())
    // end

// Main actor to start the program and read command-line arguments
actor Main
  new create(env: Env) =>
    try
      let args = env.args

      // Check if enough arguments are passed
      if args.size() < 2 then
        env.out.print("Usage: <program> <n> <step>")
        return
      end

      // Parse the arguments to U64
      let n = args(1)?.u64()?
      let step = args(2)?.u64()?

      // Create a Boss and assign tasks
      let boss = Boss(env, 1, n, 10)
      boss.assign_task(step)
    else
      env.out.print("Error: Invalid command-line arguments.")
    end
