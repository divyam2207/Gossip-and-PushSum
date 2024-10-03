actor Manager
    let _topology: String
    let _numNodes: U64
    


    new create(env: Env) =>















actor Main
  new create(env: Env) =>
    try
      let args = env.args

      // Check if enough arguments are passed
        if args.size() < 3 then
            env.out.print("Usage: <program> <n> <step>")
            return
        end

        // Parse the arguments to U64
        let numNodes = args(1)?.u64()?
        let topology = args(2)?.string()?
        let algo = args(3)?.string()?

        // Create a Boss and assign tasks
        let manager = Manager(env, numNodes, topology)

        if algo == "gossip" then
            manager.initialize_gossip()
        elseif algo == "push-sum" then
            manager.initialize_pushSum()
        else
            env.out.print("Error: Mentioned algorithm is Invalid. Mention either 'gossip' or 'push-sum'")
        end

    else
      env.out.print("Error: Invalid command-line arguments.")
    end