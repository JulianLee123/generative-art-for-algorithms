ArrayList<Node> bestSln;
ArrayList<Integer> nodeDiff = new ArrayList<Integer>();
boolean [][] hasParticle;
int minProximity = 3;//min proximity between particles
int radius = 150*2.7;
int thickestBranch = 10;//8;//5;
Color backgroundColor = color(150,255,255);
int numNodes = 35;

void setup() {
	size(1800, 1800);
	background(255,255,255);
	hasParticle = new boolean[width][height];
	float chanceOfEdge = 0.1;
	ArrayList<Node> nodes = new ArrayList<Node>();
	nodes = generateNodes(numNodes, chanceOfEdge);
	bestSln = anneal(nodes,numNodes);
}

void draw() { 
	createCircles();
	ParticleSystem ps = new ParticleSystem(nodeDiff, new PVector(width/2, height/2), thickestBranch);
	int i = 0;
	while(!ps.dead()){
		ps.next();
		ps.draw();
		i++;
		if(i > 300)
			break;
	}
	noLoop();
}