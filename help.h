#ifndef __HELP_H
#define __HELP_H

#include <iostream>
#include <cstdio>
#include <string>
#include "general.h"

namespace trains {

void Help(char* Topic = NULL);

static char* Topics[] = {"overview", "implementation", "load", "save", "print",
	"train", "quit", "relabel", "input",
	"braid", "ls", "step", "growth", "printto", "horseshoe",
	"tolerance", "precision", "reduction", "check", "help",
	"q", "exit", "dir", "hs", "tol", "prec", "gates", "run"};
const uint NumberOfTopics = 28;
char TopicIn[50];

bool PAK()
{
	char p;
	std::cout << "Enter 'q' to leave help, or press RETURN to continue... ";
	p = std::cin.get();
	if (p=='q' || p=='Q')
	{
		std::cout << '\n';
		return true;
	}
	return false;
}


void Help(char* Topic)
{
	using std::cout;
	using std::cin;

	if (!Topic)
	{
		cout << "\nType 'overview' for a general overview,\n";
		cout << "     or enter one of the following command names:\n";
		cout << "\nGRAPH INPUT COMMANDS:\n";
		cout << "     braid, horseshoe, input, load\n";
		cout << "\nGRAPH OUTPUT COMMANDS:\n";
		cout << "     print, printto, save\n";
		cout << "\nALGORITHM RUNNING COMMANDS:\n";
		cout << "     train, step, gates, reduction, run\n";
		cout << "\nOTHER COMMANDS:\n";
		cout << "     growth, check, precision, tolerance, relabel, help, quit\n";
		do
		{
			cout << "\nHelp topic: ";
			cin.getline(TopicIn,50);
			LowerCase(TopicIn);
			uint i = 0; while (TopicIn[i] == ' ') i++;
			Topic = strtok(TopicIn+i, " ");
		} while (!strlen(Topic));
	}
        uint TopicNumber;
	for (TopicNumber=0; TopicNumber<NumberOfTopics; TopicNumber++)
			if (!strcmp(Topic, Topics[TopicNumber])) break;
	switch (TopicNumber)
	{
		case 0: //Overview
			cout << "\n\n\nThis is an implementation of Bestvina and Handel's algorithm for\n";
			cout << "determining train tracks of surface homeomorphisms (Topology vol. 34\n";
			cout << "(1995), pages 109-140). It works for orientation-preserving homeomorphisms\n";
			cout << "of punctured closed orientable surfaces only.\n\n";
			cout << "There are three ways of entering an isotopy class: as an explicit graph\n";
			cout << "map (using the 'input' command); as a braid (using the 'braid' command);\n";
			cout << "and as a finite collection of periodic orbits of Smale's horseshoe map\n";
			cout << "(using the 'horseshoe' command). Graphs can also be saved to disk, or\n";
			cout << "printed to text files (in a human-readable format) with the 'save' and\n";
			cout << "'printto' commands, and loaded from disk with the 'load' command\n\n";
			cout << "One graph map is held in memory at all times (except when the program is\n";
			cout << "started and no map has yet been assigned). The algorithm is run in its\n";
			cout << "totality using the 'train' command, or a step at a time using 'step'.\n";
			cout << "These commands replace the graph map held in memory with the result of \n";
			cout << "running the algorithm (or algorithm step).\n\n";
			cout << "Once the algorithm terminates, the Thurston type of the isotopy class is\n";
			cout << "displayed. If it is a pseudo-Anosov class, the 'gates' command will\n";
			cout << "display the gates at each vertex, and the infinitesimal edges which connect\n";
			cout << "them. If it is a reducible class, then the 'reduction' command either\n";
			cout << "displays an invariant subset of edges giving rise to a reduction, or (if\n";
			cout << "there is an efficient fibred surface) the gates and infinitesimal edges at\n";
			cout << "each vertex, with the gates at at least one vertex not being connected by\n";
			cout << "the infinitesimal edges.\n\n";
			cout << "Each vertex and edge has a positive integer label. The reverse of the edge\n";
			cout << "labelled n is denoted by -n. The program keeps track of the image of each\n";
			cout << "edge, and of the edges emanating from each vertex in their correct cyclic\n";
			cout << "order (each represented by a list of positive and negative integers). See\n";
			cout << "the 'print' help screen for more details.\n\n";
                        cout << "There is a rudimentary batch processing capability, provided by the\n";
                        cout << "'run' command\n\n";
			break;

		case 1: //Implementation
			
			break;

		case 2: //Load
			cout << "\n\nLOAD\n";
			cout << "====\n\n";
			cout << "Syntax: load [filename]\n\n";
			cout << "Loads a graph map previously saved using the 'save' command. The default\n";
			cout << "extension is '.grm'\n\n";
			cout << "Examples\n";
			cout << "--------\n";
			cout << "'load example'\t\t\t(loads example.grm)\n";
			cout << "'load graph.pqr'\t\t(loads graph.pqr)\n";
			cout << "'load'\t\t\t\t(Program prompts for filename)\n";
			break;

		case 3: //Save
			cout << "\n\nSAVE\n";
			cout << "====\n\n";
			cout << "Syntax: save [filename] [comment]\n\n";
			cout << "Saves the graph map held in memory to disk in a machine-readable format.\n";
			cout << "The default extension is '.grm'. \n\n";
			cout << "The saved file consists of a list of integers, which are precisely those\n";
			cout << "which would be used when entering the graph with the 'input' command. \n\n";
			cout << "Examples\n";
			cout << "--------\n";
			cout << "'save example'\t\t\t\t(saves as example.grm)\n";
			cout << "'save'\t\t\t\t\t(Program prompts for filename)\n";
			break;

		case 4: //Print
			cout << "\n\nPRINT\n";
			cout << "=====\n\n";
			cout << "See also: Printto\n\n";
			cout << "Displays the graph map held in memory. It first describes each vertex of the\n";
			cout << "graph in turn: for each vertex, the image vertex is given, together with a list\n";
			cout << "of the edges emanating from the vertex in cyclic order. Thus, for example,\n";
			cout << "Edges at vertex are: 2 -2 5 -4\n";
			cout << "means that the vertex has valence 4, with the 4 edges at the vertex being the\n";
			cout << "start of edge 2, the end of edge 2, the start of edge 5, and the end of edge 4,\n";
			cout << "in that cyclic (anticlockwise) order.\n\n";
			cout << "Next, the edges of the graph are described: the start and end vertices of each\n";
			cout << "edge; its type (peripheral, preperipheral, or main), and the number of the\n";
			cout << "puncture which it is associated with in the peripheral case; and finally its\n";
			cout << "image, given as a sequence of edge labels describing an edge path.\n\n";
			if (PAK()) return;
			cout << "If the entire algorithm has already been run on the graph, this information\n";
			cout << "is supplemented by the results of the algorithm. The Thurston type of the\n";
			cout << "isotopy class is given. If the class is reducible, and this has been detected\n";
			cout << "because the transition matrix for the main edges is reducible, a collection\n";
			cout << "of edges corresponding to an invariant subgraph is given (see the 'reduction'\n";
			cout << "help topic for more details). If reducibility has been detected because\n";
			cout << "there is an efficient fibred surface with a vertex at which not all of the\n";
			cout << "gates are connected by infinitesimal edges, or in the pseudo-Anosov case, a\n";
			cout << "list of gates and infinitesimal edges at each vertex is given (see the 'gates'\n";
			cout << "help topic for details).\n\n";
			cout << "This will be more than a screenful of information for all but the smallest\n";
			cout << "graphs: the 'printto' command writes the same information to disk.\n";
			break;

		case 5: //Train
			cout << "\n\nTRAIN\n";
			cout << "=====\n\n";
			cout << "See also: Step\n\n";
			cout << "Runs the Bestvina-Handel algorithm on the graph map held in memory. Displays\n";
			cout << "the Thurston type of the isotopy class and (in the pseudo-Anosov case) the\n";
			cout << "growth rate and topological entropy. On completion the graph is relabelled\n";
			cout << "(see the 'relabel' help topic).\n";
			break;

		case 6: case 20: case 21://Quit
			cout << "\n\nQUIT\t\tSynonyms: exit, q\n";
			cout << "====\n\n";
			cout << "Rather obvious, this one.\n";
			break;

		case 7: //Relabel
			cout << "\n\nRELABEL\n";
			cout << "=======\n\n";
			cout << "Relabels edges and vertices in the graph.\n\n";
			cout << "Each edge and vertex in the graph is assigned an integer label. When\n";
			cout << "algorithm operations are applied to the graph, any new edges and vertices\n";
			cout << "created are assigned labels which have not previously been used. This means\n";
			cout << "that after several steps have been carried out, the largest edge and vertex\n";
			cout << "labels can be much greater than the number of edges and vertices. Issuing\n";
			cout << "the 'relabel' command causes the labels to be reassigned, so that the labels\n";
			cout << "used are consecutive integers starting with 1. Moreover, the edge labels are\n";
			cout << "so assigned that peripheral edges have the lowest labels (and are labelled in\n";
			cout << "order of the puncture to which they are associated), followed by preperipheral\n";
			cout << "edge, and finally main edges.\n\n";
			cout << "Once the algorithm has terminated, the graph is automatically relabelled, so\n";
         cout << "that it is not necessary to use this command.\n";
			break;

		case 8: //Input
			cout << "\n\nINPUT\n";
			cout << "=====\n\n";
			cout << "Inputs a graph and graph map directly from the keyboard. After entering the\n";
			cout << "number of peripheral loops, edges, and vertices in the graph, you will be\n";
			cout << "prompted first for information about each vertex in turn, and then for each\n";
			cout << "edge. If there are k peripheral loops, m edges, and n vertices, then the\n";
			cout << "punctures associated to the peripheral loops are labelled from 1 to k, the\n";
			cout << "edges from 1 to m, and the vertices from 1 to n.\n\n";
			cout << "For each vertex, you will be asked for its image, and then for the labels of\n";
			cout << "the edges emanating from it. These should be entered in cyclic (anticlockwise)\n";
			cout << "order, the list terminating with zero (see the examples below). For each edge,\n";
			cout << "you will first be asked, if the graph contains peripheral loops, whether or not\n";
			cout << "it is a peripheral edge. If it is, you are then prompted for the label of the\n";
			cout << "puncture which the corresponding peripheral loop surrounds. Finally, you are\n";
			cout << "prompted for the image of the edge, which should be given as a list of\n";
			cout << "(positive or negative) edge labels, terminated with zero.\n";
			if (PAK()) return;
			cout << "The program performs some rudimentary sanity checking on the graph map (it\n";
			cout << "checks that it makes sense as a graph map), but it is your responsibility to\n";
			cout << "ensure first that the edges at each vertex are given in the correct cyclic\n";
			cout << "order, and second that the graph map can be realised by an orientation-\n";
			cout << "preserving isotopy class on an orientable surface. The program may come to an\n";
			cout << "abrupt end in the course of the algorithm if these conditions aren't satisfied.\n\n";
			if (PAK()) return;
			cout << "Example 1\n";
			cout << "---------\n\n";
			cout << "To enter the example in section 6.1 of Bestvina and Handel: the edges there\n";
			cout << "labelled a, b, c, and d will be labelled 1, 2, 3, and 4 respectively.\n";
			cout << ">input\n";
			cout << "Enter number of peripheral loops, edges, and vertices: 0 4 1\n";
			cout << "Vertex number 1:\n";
			cout << "Image vertex: 1\n";
			cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
			cout << "1 2 -1 -2 -4 -3 4 3 0\n";
			cout << "Edge number 1 from 1 to 1:\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "1 -2 -1 2 -4 -3 -1 0\n";
			cout << "Edge number 2 from 1 to 1:\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "1 3 4 -2 1 2 3 4 -2 0\n";
			cout << "Edge number 3 from 1 to 1:\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "3 3 4 -2 0\n";
			cout << "Edge number 4 from 1 to 1:\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "2 3 4 -2 0\n\n";
			if (PAK()) return;
			cout << "Example 2\n";
			cout << "---------\n\n";
			cout << "To enter the example in section 6.2 of Bestvina and Handel: the edges there\n";
			cout << "labelled alpha, beta, gamma, a, and b will be labelled 1, 2, 3, 4, and 5.\n";
			cout << ">input\n";
			cout << "Enter number of peripheral loops, edges, and vertices: 3 5 3\n";
			cout << "Vertex number 1:\n";
			cout << "Image vertex: 1\n";
			cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
			cout << "1 -1 -4 0\n";
			cout << "Vertex number 2:\n";
			cout << "Image vertex: 2\n";
			cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
			cout << "2 -2 5 4 0\n";
			cout << "Vertex number 3:\n";
			cout << "Image vertex: 3\n";
			cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
			cout << "3 -3 -5 0\n";
			if (PAK()) return;
			cout << "Edge number 1 from 1 to 1:\n";
			cout << "Enter 1 if peripheral, 0 otherwise: 1\n";
			cout << "Enter puncture which edge is about: 1\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "1 0\n";
			cout << "Edge number 2 from 2 to 2:\n";
			cout << "Enter 1 if peripheral, 0 otherwise: 1\n";
			cout << "Enter puncture which edge is about: 2\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "2 0\n";
			cout << "Edge number 3 from 3 to 3:\n";
			cout << "Enter 1 if peripheral, 0 otherwise: 1\n";
			cout << "Enter puncture which edge is about: 3\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "3 0 \n";
			cout << "Edge number 4 from 2 to 1:\n";
			cout << "Enter 1 if peripheral, 0 otherwise: 0\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "2 5 3 -5 4 0\n";
			cout << "Edge number 5 from 2 to 3:\n";
			cout << "Enter 1 if peripheral, 0 otherwise: 0\n";
			cout << "Enter labels of image edges, ending with 0:\n";
			cout << "2 5 3 -5 4 1 -4 5 -3 -5 2 5 3 -5 4 1 -4 5 -3 0\n";
			break;

		case 9: //Braid
			cout << "\n\nBRAID\n";
			cout << "=====\n\n";
			cout << "Constructs a graph map corresponding to the isotopy class on the n-punctured\n";
			cout << "disc (i.e. (n+1)-punctured sphere) described by a given n-braid. The\n";
			cout << "program prompts for the number n of strings (which must be at least three, or\n";
			cout << "an error message is issued), and then for the braid generators. These should\n";
			cout << "be entered as a sequence of non-zero integers between -(n-1) and (n-1),\n";
			cout << "terminated with zero. If there are many generators, it can be convenient to\n";
			cout << "separate some of them with carriage returns rather than spaces. The graph\n";
			cout << "which carries the isotopy class is constructed as follows: there are peripheral\n";
			cout << "edges, labelled 1 to n, about each puncture corresponding to a braid string,\n";
			cout << "ordered in the natural way, with the vertices on these loops also labelled from\n";
			cout << "1 to n. The main edges have labels from n+1 to 2n-1, with edge k joining vertex\n";
			cout << "k-n to vertex k-n+1, in such a way that the edge path k k+1 passes over the top\n";
			cout << "of puncture number k-n+1\n\n";
			cout << "Example\n";
			cout << "-------\n";
			cout << "To enter the 5-braid sigma_3 sigma_2 sigma_4^{-1} sigma_3 sigma_2 sigma_1:\n";
			cout << ">braid\n";
			cout << "Enter number of braid strings: 5\n";
			cout << "Enter braid generators separated by spaces, ending with 0:\n";
			cout << "3 2 -4 3 2 1 0\n";
			break;

		case 10: case 22://Ls
			cout << "\n\nLS\t\tSynonym: dir\n";
			cout << "==\n\n";
			cout << "Lists all files in the working directory with extension '.grm'\n";
			cout << "(the default extension for graph map files).\n\n";
			cout << "This command is not defined for this implementation. Sorry. \n\n";
			break;

		case 11: //Step
			cout << "\n\nSTEP\n";
			cout << "====\n\n";
			cout << "Syntax: Step [n]\n";
			cout << "See Also: Train\n\n";
			cout << "Runs the Bestvina-Handel algorithm on the graph map held in memory for n steps,\n";
			cout << "or until the algorithm terminates. If the algorithm does terminate, the\n";
			cout << "Thurston type of the isotopy class is displayed, together with the growth rate\n";
			cout << "and topological entropy in the pseudo-Anosov case; the graph is also relabelled\n";
			cout << "(see the 'relabel' help topic for details). The default value of n is 1.\n";
			cout << "After each step, the type of operation carried out is displayed.\n\n";
			cout << "Note: because of the way the algorithm is implemented, many of the moves 'clean\n";
			cout << "up' after themselves by performing other moves. These supplementary moves are\n";
			cout << "not displayed.\n";
			break;

		case 12: //Growth
			cout << "\n\nGROWTH\n";
			cout << "======\n\n";
			cout << "Displays the growth rate and topological entropy of the graph map\n";
			cout << "currently held in memory, provided that the transition matrix for\n";
			cout << "the main edges is irreducible.\n";
			break;

		case 13: //Printto
			cout << "\n\nPRINTTO\n";
			cout << "=======\n\n";
			cout << "Syntax: Printto [filename]\n";
			cout << "See Also: Print\n\n";
			cout << "Displays the properties of the graph held in memory to the given file. The\n";
			cout << "format is exactly as descibed in the 'print' help topic. If the command is\n";
			cout << "issued without a filename, then the filename is prompted for.\n";
			break;

		case 14: case 23://Horseshoe
			cout << "\n\nHORSESHOE\t\tSynonym: hs\n";
			cout << "=========\n\n";
			cout << "Constructs a graph map carrying the isotopy class of Smale's horseshoe map\n";
			cout << "of the sphere, punctured at infinity and at the points of a finite number\n";
			cout << "of periodic orbits. The program prompts for the number of periodic orbits,\n";
			cout << "and then for the symbolic code of each one. These codes use the symbols 0 and\n";
			cout << "1, where 1 is the code of the orientation-reversing fixed point (see for\n";
			cout << "example Nonlinearity vol. 7 (1994) pages 861-924 for the particular model of\n";
			cout << "the horseshoe which is used). An error message is given if any of the codes\n";
			cout << "describes an orbit whose period is less than the length of the code (e.g.\n";
			cout << "1010), or if two of the codes describe the same orbit (e.g. 10010 and 00101).\n";
			cout << "If the orbits have n points in total, then the graph which carries the\n";
			cout << "isotopy class is constructed as follows: there are peripheral edges, labelled\n";
			cout << "1 to n, about each puncture other than infinity, ordered according to the\n";
			cout << "horizontal ordering of points in the horseshoe, with the vertices on these\n";
			cout << "loops also labelled from 1 to n. The main edges have labels from n+1 to 2n-1,\n";
			cout << "with edge k joining vertex k-n to vertex k-n+1, in such a way that the edge\n";
			cout << "path k k+1 passes over the top of puncture number k-n+1.\n\n";
			if (PAK()) return;
			cout << "Example\n";
			cout << "-------\n";
			cout << ">horseshoe\n";
			cout << "Number of orbits: 2\n";
			cout << "Enter code of orbit 1: 10010\n";
			cout << "Enter code of orbit 2: 00010101\n";
			break;

		case 15: case 24://Tolerance
			cout << "\n\nTOLERANCE\t\tSynonym: tol\n";
			cout << "=========\n\n";
			cout << "See also: precision, check\n\n";
			cout << "Alters the accuracy with which floating point calculations are carried out.\n";
			cout << "The starting value is 10^{-9}. On entering the command 'tolerance', the old\n";
			cout << "value is displayed, and a new value is prompted for.\n\n";
			cout << "The program uses floating point arithmetic to calculate the growth rate of\n";
			cout << "graph maps, and to decide in which direction valence two isotopies should be\n";
			cout << "performed. By default, after each application of the algorithm step 'folding\n";
			cout << "to decrease lambda', the program checks that the growth rate has decreased\n";
			cout << "by at least the tolerance, and issues an error message if it has not. This is\n";
			cout << "to prevent the program hanging in an infinite loop if something goes wrong.\n";
			cout << "When the graph has many edges, the default value of the tolerance may not be\n";
			cout << "small enough to detect the decrease in growth rate. In this case there are 2\n";
			cout << "options: either to decrease the tolerance (which will slow the algorithm), or\n";
			cout << "to issue the 'check' command, which disables checking that the growth is\n";
			cout << "decreasing. The second option should be used with caution: if the tolerance\n";
			cout << "is not small enough to detect the decrease in growth rate, it may not be small\n";
         cout << "enough to make the correct decision when performing valence two isotopies.\n";
			break;

		case 16: case 25://Precision
			cout << "\n\nPRECISION\t\tSynonym: prec\n";
			cout << "=========\n\n";
			cout << "Syntax: precision [n]\n";
			cout << "See also: tolerance\n\n";
			cout << "Alters the number of significant figures with which floating point numbers\n";
			cout << "are displayed. The default value is 6. The command 'precision' on its own\n";
			cout << "displays the old precision, and prompts for a new value, while 'precision n'\n";
			cout << "changes the precision to n without further prompting.\n\n";
			cout << "Adjusting the precision does not affect the accuracy with which floating\n";
			cout << "point calcuations are performed: this is changed using the 'tolerance'\n";
			cout << "command.\n";
			break;

		case 17: //Reduction
			cout << "\n\nREDUCTION\n";
			cout << "=========\n\n";
			cout << "If the graph map held in memory has been found to represent a reducible\n";
			cout << "isotopy class, and if reducibility has been detected because the transition\n";
			cout << "matrix corresponding to the main edges is reducible, then this command will\n";
			cout << "display a list of main edge labels corresponding to a reduction. The images\n";
			cout << "of the main edges listed may contain peripheral or preperipheral edges, but\n";
			cout << "contain no other main edges.\n";
			break;

		case 18: //Check
			cout << "\n\nCHECK\n";
			cout << "=====\n\n";
			cout << "See also: tolerance\n\n";
			cout << "Toggles checking to ensure that the growth rate has decreased after each\n";
			cout << "application of the algorithm step 'folding to decrease lambda'. By default,\n";
         cout << "checking is enabled. See the 'tolerance' help entry for more details.\n";
			break;

		case 19: //Help
			cout << "\n\nHELP\n";
			cout << "====\n\n";
			cout << "Syntax: help [command]\n\n";
			cout << "Displays help information. The command 'help' issued on its own displays a\n";
			cout << "list of commands, and prompts for the command on which help is requested.\n";
			cout << "Typing 'help command' causes the help entry for 'command' to be displayed\n";
         cout << "directly.\n";
			break;

		case 26: //Gates
			cout << "\n\nGATES\n";
			cout << "=====\n\n";
			cout << "If the graph map held in memory has been found to represent a pseudo-Anosov\n";
			cout << "isotopy class, or a reducible class for which reducibility has been detected\n";
			cout << "because there is an efficient fibred surface with a vertex at which not all\n";
			cout << "of the gates are connected by infinitesimal edges, then this command will\n";
			cout << "display lists of gates and infinitesimal edges at each vertex. The gates\n";
			cout << "are listed in cyclic (anticlockwise) order around the vertex.\n";
			break;

                case 27: //run
                        cout << "\n\nRUN\n";
                        cout << "===\n\n";
                        cout << "Syntax: run [filename]\n\n";
                        cout << "This command provides rudimentary batch processing - a list of braids can be\n";
                        cout << "processed consecutively. The following five commands are recognised in batch\n";
                        cout << "files: \n\n";
                        cout << "TO filename\n";
                        cout << "-----------\n\n";
                        cout << "Specifies the file to which subsequent output should be directed. The command\n";
                        cout << "TO CON directs output to the console\n\n";
                        cout << "STR n\n";
                        cout << "-----\n\n";
                        cout << "Specifies that the following braids should be considered to be on n strings.\n";
                        cout << "The command STR AUTO directs the program to assume that each braid is on the\n";
                        cout << "least number of strings for which it makes sense.\n\n";
                        cout << "OUT specifier\n";
                        cout << "-------------\n\n";
                        cout << "Tells the program how to format the output from each braid processed. The\n";
                        cout << "specifier is a combination of the following symbols:\n";
                        cout << "t b g / . d\n";
                        cout << "(with optional spaces which are ignored). These direct the program to output,\n";
                        cout << "respectively: the Thurston type; the braid itself; the growth rate; a carriage\n";
                        cout << "return; a space; and a detailed description of the train track as provided\n";
                        cout << "by the PRINT command.\n\n";
                        cout << "BR braid\n";
                        cout << "--------\n\n";
                        cout << "Specifies a braid, given by a sequence of positive and negative integers,\n";
                        cout << "terminated with a zero. The program determines the train track of the\n";
                        cout << "corresponding isotopy class, and then outputs the information specified\n";
                        cout << "by OUT.\n\n";
                        cout << "SAVE filename\n";
                        cout << "-------------\n\n";
                        cout << "Saves the current graph map to the given file. The default extension is .grm\n\n\n";
                        if (PAK()) return;
                        cout << "\n\nThe TO, STR, and OUT commands must each appear alone on a single line of the file.\n";
                        cout << "The BR command must begin on a new line but the braid itself can, if desired,\n";
                        cout << "be spread over several lines. The default settings are:\n";
                        cout << "TO CON, STR AUTO, and OUT b/t.g/\n\n\n";
                        cout << "Example\n";
                        cout << "-------\n\n";
                        cout << "Suppose the file ex.btt contains the lines below. Then the command run ex.btt\n";
                        cout << "processes the 3 string braid 1 -2, the four string braid 1 -2 3, and the five\n";
                        cout << "string braid 1 -2 3 in turn. For the first, it displays the braid, Thurston\n";
                        cout << "type and growth rate to the console. For the second, it puts the same information\n";
                        cout << "in the file test.out, and also saves the resulting train track to test.grm;\n";
                        cout << "and for the third, it puts full details in test.out\n\n";
                        cout << "br 1 -2 0\nto test.out\nbr 1 -2 3 0\nsave test\nstr 5\nout b/t.g/d//\nbr 1 -2 3 0\n";
                        break;


		default:
			cout << "Help topic not recognised\n";
	}
}


}


#endif
