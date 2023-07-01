ArrayList<Node> anneal(ArrayList<Node> nodes, int numNodes){
	ArrayList<Node> newSln, bestSln, currSln;
	currSln = new ArrayList<Node>();
	bestSln = new ArrayList<Node>();
  float T = 0.04, minT = 0.00001, alpha = 0.9, ap;
  int iterationsPerTemp = 5;
  while(T > minT){
    for(int i = 0; i < iterationsPerTemp; i++){
      newSln = neighborSln(nodes, currSln, numNodes);
      ap = acceptance_probability(cost(currSln, numNodes), cost(newSln, numNodes), T);
      if(ap > random(1)){
				nodeDiff.add(newSln.size());
				if(cost(newSln, numNodes) < cost(bestSln, numNodes)){
					bestSln = new ArrayList<Node>();
					for(int j = 0; j < newSln.size(); j++)
						bestSln.add(newSln.get(j));
				}
        currSln = newSln;
      }
    }
		T *= alpha;
  }
	for(int i = 0; i < nodeDiff.size(); i++)
		nodeDiff.set(i,bestSln.size() - nodeDiff.get(i));
	return bestSln;
}

int acceptance_probability(int oldCost, int newCost, float T){
  if(newCost < oldCost)
    return 1;
  return (int)pow(2.718,(newCost - oldCost)/T);
}

int cost(ArrayList<Node> sln, int numNodes){
  return numNodes - sln.size();
}

ArrayList<Node> generateNodes(int numNodes, float edgeChance){
  ArrayList<Node> allNodes = new ArrayList<Node>();
  for(int i = 0; i < numNodes; i++)
    allNodes.add(new Node(i));
  for(int i = 0; i < numNodes; i++)
    for(int j = i + 1; j < numNodes; j++){
      if(random(1) < edgeChance){
        allNodes.get(i).addAdj(allNodes.get(j));//add connection
        allNodes.get(j).addAdj(allNodes.get(i));
      }
    }
  return allNodes;
}

ArrayList<Node> neighborSln(ArrayList<Node> nodes, ArrayList<Node> ogSln, int numNodes){//returns a neighboring solution (list sorted based on ID)
  ArrayList<Node> newSln = new ArrayList<Node>();
	for(int i = 0; i < ogSln.size(); i++)
		newSln.add(ogSln.get(i));
  int newNodeCount = (int)random(numNodes - ogSln.size());//choose one of the remaining nodes: corresponds to the nth remaining node
  int newNodeID = 0;
  for(int i = 0, currIdx = 0; i < numNodes; i++){//map random number to the corresponding node that isnt already in ogSln
    if(ogSln.size() > currIdx && ogSln.get(currIdx).ID == i){//already there
      currIdx++;
		}
    else{
      if(newNodeCount == 0){
        newSln.add(currIdx,nodes.get(i));
        newNodeID = i;
				/*print("aaaa");
				print(i);
				print(nodes.get(i).ID);
				for(int i = 0; i < newSln.get(currIdx).adjList.size(); i++)
					print(newSln.get(currIdx).adjList.get(i).ID);
				print("bbbb");*/
        break;
      }
      newNodeCount--;
    }
  }
  int newNodeAdjIdx = 0;
  Node newNode = nodes.get(newNodeID);
  for(int i = 0; i < newSln.size(); i++){//remove bad edges
    if(newSln.get(i).ID == newNodeID)
      continue;
    while(newNodeAdjIdx < newNode.adjList.size() && newSln.get(i).ID > newNode.adjList.get(newNodeAdjIdx).ID){
      newNodeAdjIdx++;
    }
    if(newNodeAdjIdx < newNode.adjList.size() && newSln.get(i).ID == newNode.adjList.get(newNodeAdjIdx).ID){//bad edge: shared edge
			/*print("in");
			print(newSln.get(i).ID);
			print(newNode.adjList.get(newNodeAdjIdx).ID);
			print(newNodeAdjIdx);
			print(newNodeID);*/
      newSln.remove(i--);
		}
  }
  return newSln;
}

class Node{
  ArrayList<Node> adjList;//sorted by ID 
  int numEdges;
  int ID;
  Node(int ID){
    numEdges = 0;
    this.ID = ID;
    adjList = new ArrayList<Node>();
  }
  void addAdj(Node adj){
    int idx = 0;
    while(adjList.size() > idx && adjList.get(idx).ID < adj.ID)
      idx++;
    adjList.add(idx,adj);
  }
}