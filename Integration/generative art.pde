//each particle creates a branch
class Particle {
	float angle;//current angle at which the particle is moving
	float ogAngle;//original angle of the particle
	float velocity;//speed at which the particle is moving
	PVector position;//current position of the particle
	PVector origin;//original position of the particle
	int numPosBranch;//possible number of branches
	float d;//diameter
	boolean dead;//whether the particle needs to be removed (eg. if it is about to collide to another particle)
	float branchProbability;//probability of generating a new branch (given the number of generated branches < the max number of branches allowed)
	int step;//how many times has the next() method been called
	boolean [][] mask;//for hasParticle
	boolean mainBranch;
	Particle(PVector pos, int numPosBranch, float angle, float diameter, boolean main){
		mainBranch = main;
		step = 0;
		mask = new boolean[width][height];
		position = new PVector(pos.x,pos.y);
		origin = new PVector(pos.x,pos.y);
		this.numPosBranch = numPosBranch;
		velocity = min(diameter/2,3);
		this.angle = angle;
		d = max(diameter,1);
		dead = false;
		updateHasParticle();
		branchProbability = 0.15;
		ogAngle = angle;
	}
	void updateHasParticle(){//updates pixels that contain a branch
		for(int i = max(position.x - d,0); i < min(position.x + d, width - 1); i++){//update hasParticle
			for(int j = max(position.y - d,0); j < min(position.y + d, height - 1); j++){
				hasParticle[(int)i][(int)j] = true;
				mask[(int)i][(int)j] = true;
			}
		}
	}
	void next(){//update position and angle
		step++;
		if(step > 7)
			if(mainBranch)//less deviation to fill space
				this.angle = angle + random(-PI/10,PI/10);
			else
				this.angle = angle + random(-PI/6,PI/6);
		if(angle > PI*2/3 + ogAngle)//stop branches from completely making a 180
			angle = PI*2/3 + ogAngle;
		else if(angle < ogAngle - PI*2/3)
			angle = ogAngle - PI*2/3;
		/*int futureX = minProximity*cos(angle) + position.x, futureY = minProximity*sin(angle) + position.y;
		for(int i = max(futureX - minProximity/2,0); i < min(futureX + minProximity/2, width - 1); i++){
			for(int j = max(futureY - minProximity/2,0); j < min(futureY + minProximity/2, height - 1); j++){
				if(hasParticle[(int)i][(int)j]){//if we continue the branch, it will collide with another particle
					dead = true;
					return;
				}
			}
		}*/
		position.x += 2*3*velocity*cos(angle);//looking at future move for collisions
		position.y += 2*3*velocity*sin(angle);
		if(step > 2 && !mainBranch && sqrt(pow(abs(origin.x - position.x), 2) + pow(abs(origin.y - position.y),2)) > 12){//make sure you have already gone far enough from origin
			for(int i = max(position.x - minProximity,0); i < min(position.x + minProximity, width - 1); i++){
				for(int j = max(position.y - minProximity,0); j < min(position.y + minProximity, height - 1); j++){
					if(hasParticle[(int)i][(int)j] && !mask[(int)i][(int)j]){//if we continue the branch, it will collide with another particle
						dead = true;
						return;
					}
				}
			}
		}
		position.x -= 2.5*2*velocity*cos(angle);
		position.y -= 2.5*2*velocity*sin(angle);
		if(step > 1 && hasParticle[(int)position.x][(int)position.y] && !mask[(int)position.x][(int)position.y]){//more leniant condition that must always apply to prevent collisions
					dead = true;
					return;
		}
		updateHasParticle();
	}
	boolean isDead(){//see if particle is out of bounds or if it will collide with previous particle 
		if(dead || sqrt(pow(abs(position.x - width/2),2) + pow(abs(position.y - height/2),2)) > radius)
			return true;
		return false;
	}
	Particle newBranch(int newNumBranch, ArrayList<PVector> origins){//see if we should add branch
		if(branchProbability < random(1) || numPosBranch == 0)
			return null;
		for(int i = 0; i < origins.size(); i++)
			if(sqrt(pow(abs(position.x - origins.get(i).x),2) + pow(abs(position.y- origins.get(i).y),2)) < 10)//make sure no two branch origins are too close
				return null;
		numPosBranch--;
		float newAngle = angle + (random(1) < 0.5 ? 1 : -1) * random(PI/3,PI/2);//new angle deviates enough from current branch's angle
		return new Particle(new PVector(position.x, position.y), newNumBranch, newAngle, d - 4, false);
	}
	void draw(){
		fill(200);
		stroke(200,200,200);
		ellipse(position.x,position.y,(d+1)/2,(d+1)/2);
	}
}

//creates the tree
class ParticleSystem {
	ArrayList<PVector> origins;//origin coordinate of each branch
	ArrayList<Particle> particles;//each moving particle drawn over multiple timesteps essentially makes a branch
  /*the maximum number of branches a particle can have: this list is based on the algorithm, namely the difference in value between the size
	 of the optimal solution and the size of the nth solution found. This list tends to have steadily decreasing values
	 with a few spikes, representing when the algorithm has chosen to continue with a "subotminal" solution to find a new peak*/
	ArrayList<int> numBranch; 
	int currIdx;//current index for numBranch, increases every time a particle is added
	ParticleSystem(ArrayList<int> numBranch, PVector origin, int ogWidth){//branch width
		origins = new ArrayList<PVector>();
		this.numBranch = new ArrayList<int>();
		this.particles = new ArrayList<Particle>();
		for(int i = 0; i < numBranch.size(); i++){
			this.numBranch.add(numBranch.get(i)); 
		}
		currIdx = 0;
		float initialAngle = 0;
		/*start tree off by adding four branches (represented by particles), each separated by 90°, where the number 
		of new potential branches each of these branches can have is based on numBranch*/
		for(i = 4; i > 0; i--){
			origins.add(new PVector(origin.x,origin.y));
			particles.add(new Particle(origin,numBranch.get(currIdx++), initialAngle, ogWidth, true));
			initialAngle += PI*1/2;
		}
	}
	void next(){
		//one time step: updates the particle positions
		for(Particle p : particles)
			p.next();
		//remove dead particles (collided or out of bounds)
		for(int i = particles.size() - 1; i >= 0; i--){
			if(particles.get(i).isDead())
				particles.remove(i);
		}
		//add new branches
		Particle newP;
		for(int i = 0; i < particles.size(); i++){
			newP = particles.get(i).newBranch(numBranch.get(currIdx),origins);
			if(newP != null){
				origins.add(new PVector(newP.position.x,newP.position.y));
				particles.add(newP);
				currIdx++;
			}
		}
	}
	void draw(){
		//creates branches by drawing a circle representing the particle's location at each timestep
		for(Particle p : particles)
			p.draw();
		//colors to origin of the particle, the "branching point", red
		for(PVector ogn : origins){
			fill(255,0,0);
			noStroke();
			//ellipse(ogn.x,ogn.y,5,5);
		}
	}
	boolean dead(){//checks if every particle has died
		if(particles.size() == 0)
			return true;
		return false;
	}
}

void createCircles(){//creates all circles
	//create the largest outer circle (which essentially acts as the background)

	//strokeWeight(5);
	//noStroke();
	//fill(255);
	//ellipse(width/2,height/2,radius*2+200,radius*2+200);//set background color/border
	/*Create outer sectors: the length of each sector is determined based on the difference in value between the size
	 of the optimal solution and the size of the nth solution found.
	 */
	noStroke();
	int total = 0;
	for(int i = 0; i < nodeDiff.size(); i++){
		total += nodeDiff.get(i);
	}
	float angleInc = TWO_PI/total, currAngle = -PI/2;
	for(int i = 0; i < nodeDiff.size(); i++){
		fill(random(255),random(255),random(255));
		arc(width/2,height/2,radius*2+60*2.7,radius*2+60*2.7, currAngle, currAngle + angleInc*nodeDiff.get(i));//creates the sector
		currAngle += angleInc*nodeDiff.get(i);
	}
  //color the middle part of the circle back to the background color as this is where the tree needs to go
	fill(0,0,0,150);
	ellipse(width/2,height/2,radius*2+10*2.7,radius*2+10*2.7);
	//create outer smaller circles which form a ring/circle
	angleInc = TWO_PI/numNodes;
	int miniCircleRad = 50*2.7;
	for(int i = 0, idx = 0; i < numNodes; i++){
		noStroke();
		if(idx < bestSln.size() && bestSln.get(idx).ID == i){
			idx++;
			//fill(0,199,255);//the color of the circle is based on the best solution of the simulated annealing, so each circle is effectively the node
			fill(125,160);
		}
		else
			fill(0,160);
			//fill(200,255,255);
		ellipse(width/2+cos(angleInc*i)*(miniCircleRad/2+radius+40*2.7),height/2+sin(angleInc*i)*(miniCircleRad/2+radius+40*2.7),miniCircleRad,miniCircleRad);
	}
}