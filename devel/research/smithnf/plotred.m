% Trains: Version 4.0 March 2008
% An implementation of the Bestvina-Handel algorithm
% For train tracks of surface automorphisms
% 
% Type 'help' for a list of commands
% > braid
% Enter number of braid strings: 5
% Enter braid generators separated by spaces, ending with 0:
% -3  1 -4  2 -3 -1 -2  3 -2  4  3  4 0
% > train
% Isotopy class is Reducible
% > print
% Graph on surface with 5 peripheral loops:
% Vertex number 1 with image vertex 5:
% Edges at vertex are: 1 -1 6 
% Region 1
% 
% Vertex number 2 with image vertex 1:
% Edges at vertex are: 4 -4 8 -7 
% Region 3
% 
% Vertex number 3 with image vertex 3:
% Edges at vertex are: 5 -5 -8 
% Region 4
% 
% Vertex number 4 with image vertex 4:
% Edges at vertex are: -3 9 3 
% Region 2
% 
% Vertex number 5 with image vertex 2:
% Edges at vertex are: -2 -9 -6 7 2 
% Region 1
% 
% Edge number 1 from vertex 1 to vertex 1:
% Type: Peripheral about puncture number 1
% Image is: 2 
% Path (1 -> 1):  1 -1 
% 
% Edge number 2 from vertex 5 to vertex 5:
% Type: Peripheral about puncture number 2
% Image is: 4 
% Path (1 -> 1):  -2 2 
% 
% Edge number 3 from vertex 4 to vertex 4:
% Type: Peripheral about puncture number 3
% Image is: 3 
% Path (2 -> 2):  -3 3 
% 
% Edge number 4 from vertex 2 to vertex 2:
% Type: Peripheral about puncture number 4
% Image is: 1 
% Path (3 -> 3):  -4 4 
% 
% Edge number 5 from vertex 3 to vertex 3:
% Type: Peripheral about puncture number 5
% Image is: 5 
% Path (4 -> 4):  -5 5 
% 
% Edge number 6 from vertex 1 to vertex 5:
% Type: Main
% Image is: 7 4 8 5 -8 -4 8 -5 -8 -4 -7 -2 7 4 8 5 -8 -4 -7 2 -6 -1 6 -2 7 4 8 -5 -8 -4 -7 2 7 4 8 5 -8 
% Path (1 -> 1):  
% 
% Edge number 7 from vertex 5 to vertex 2:
% Type: Main
% Image is: 8 -5 -8 -4 -7 -2 7 4 8 5 -8 -4 -7 2 -6 
% Path (1 -> 3):  -2 -3 
% 
% Edge number 8 from vertex 2 to vertex 3:
% Type: Main
% Image is: 6 -2 7 4 8 -5 -8 -4 -7 2 7 4 8 5 -8 4 8 -5 -8 -4 -7 -2 7 4 8 5 -8 -4 8 -5 -8 -4 -7 -2 7 4 8 
% Path (3 -> 4):  4 
% 
% Edge number 9 from vertex 4 to vertex 5:
% Type: Main
% Image is: 9 -2 7 4 8 -5 -8 -4 -7 2 7 4 8 5 -8 
% Path (2 -> 1):  2 
% 
% Reducible Isotopy class
% The following main edges and their images constitute an invariant subgraph:
% 6 7 8

% Edge number 6 from vertex 1 to vertex 5:
% Path (1 -> 1):  
% Edge number 7 from vertex 5 to vertex 2:
% Path (1 -> 3):  -2 -3 
% Edge number 8 from vertex 2 to vertex 3:
% Path (3 -> 4):  4 

b = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
l = loop([0 -1 -1 -1  0  1  0  0]);

gens = [];
for i = 1:length(b)
  subplot(3,4,i)
  plot(braid(gens,5)*l)
  title(sprintf('%d (%s)',i,num2str(gens)))
  gens = [gens b.word(i)];
end
