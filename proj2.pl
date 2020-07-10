:- ensure_loaded(library(clpfd)).
:- ensure_loaded(library(apply)).
:- ensure_loaded(library(lists)).

% File : proj2.pl
% Author : Haoyu (Vincent) Tian 
% Student ID: 1125895
% Purpose: An implementation to solve the maths puzzle written in Prolog

% -----------------------------------------------------------------------------
% Project Description
%
% This code implements a solution to the given maths puzzle. The solution must
% satisfy the following constraints(ignoring the heading values):
%    1) Each row/column must contain no repeated digits between 1 and 9
%       (inclusive)
%    2) All the values in the diagonal of the puzzle must be equal
%    3) The values in each row and column must either sum or multiply to the 
%       value of the heading for that row/column.
%
% Assumptions Made:
%    1) All Headings provided are digits ("...and all the header squares of the 
%        puzzle (plus the ignored corner square) are bound to integers")
%    2) When puzzle_solution/1 is called, its argument will be a proper list of
%       proper lists.
%    3) Code will only be tested with proper puzzles and if puzzle is not 
%       solvable, the predicate will fail. If predicate succeeds, there will
%       only be one valid solution.
%    4) The puzzle is square ("A maths puzzle will be represented as a list of 
%       lists, each of the same length").
% -----------------------------------------------------------------------------
% Libraries Usage
%     
% Functions used in library : (clpfd)
%     - transpose/2 
%     - all_distinct/1 
%     - use of arithmetic constraints '#=/2' to evaluate relations in both
%       directions
%     - label/1 -> equivalent to labeling/2, used to assign a val to each Vars
%                  until all values in Vars are ground. Domain of each Vars must
%                  be finite.
%     
% Functions used in library : (apply)
%     - maplist/2 
%
% Functions used in library : (lists)
%     - nth0/3 
%
% -----------------------------------------------------------------------------

% puzzle_solution(-Puzzle)
% puzzle_solution(+Puzzle)
% puzzle_solution/1 is a predicate that holds when a Puzzle is solvable.
% The predicate returns a valid solution by going through the process:
%    1) Transpose the Puzzle to get a list of the columns
%    2) Check constraint 1 (above)
%    3) Check constraint 2 (above)
%    4) Check constraint 3 (above)
%    5) Once we have a finite domain of variables we ground them.
puzzle_solution(Puzzle) :-
    transpose(Puzzle, Columns),
    no_repeats_puzzle(Puzzle),
    no_repeats_puzzle(Columns),
    set_diagonal_value(Puzzle),
    valid_rows(Puzzle),
    valid_rows(Columns),
    ground_puzzle(Puzzle).

% -----------------------------------------------------------------------------

%Constraint 1: Each row/column contains no repeated digits

% no_repeats_puzzle(-Puzzle)
% no_repeats_puzzle(+Puzzle)
% no_repeats_puzzle/1 checks for no repeated digits in a puzzle by checking 
% through each row of the puzzle.
no_repeats_puzzle(Puzzle) :-
    Puzzle = [_|Rows],
    maplist(distinct_row,Rows).

% distinct_row(+List)
% distinct_row(-List)
% distinct_row/1 checks for no repeated digits in a row and that all digits in 
% a row are between 1 and 9
distinct_row([_|Row]) :-
    Row ins 1..9,
    all_distinct(Row).

% -----------------------------------------------------------------------------

% Constraint 2: All values in diagonal must be the same

% set_diagonal_value([_|+List])
% set_diagonal_value([_|-List])
% set_diagonal_value/1 takes in a puzzle with the headings removed, 
% gets the number of the 1st index of the first row and sets Value equal to that
% number. Value is known as the diagonal value.
set_diagonal_value([_|[Row1|Rows]]) :-
    nth0(1,Row1,Value),
    valid_diagonals(Rows,Value).

% valid_diagonals(+List, +Value)
% valid_diagonals(-List, +Value)
% valid_diagonals(+List, -Value)
% valid_diagonals(-List, -Value)
% valid_diagonals/2 takes in a list of lists and a Value and checks that the 
% following rows of the subsequent indexes equal to that Value. This checks that
% the diagonals of the puzzle are equal.
valid_diagonals([Row|Rows], Value) :-
    valid_diagonals([Row|Rows], 2, Value).
valid_diagonals([],_,_).
valid_diagonals([Row|Rows],N,Value) :-
    N1 #= N + 1,
    nth0(N,Row,Value),
    valid_diagonals(Rows,N1,Value).

% -----------------------------------------------------------------------------

% Constraint 3: Each row/column must either have all the elements sum or 
% multiply to the heading value

% valid_rows(-Puzzle)
% valid_rows(+Puzzle)
% valid_rows/1 takes in a Puzzle and makes sure that the values of each row each
% sum to or multiply to the value of the heading for that row.
valid_rows(Puzzle) :-
    Puzzle = [_|Rows],
    maplist(valid_row,Rows).

% valid_row([+Heading|+Row])
% valid_row([+Heading|-Row])
% valid_row([-Heading|+Row])
% valid_row([-Heading|-Row])
% valid_row/1 takes in a row and checks whether the row sums or multiplies to 
% the heading value.
valid_row([Heading|Row]) :- check_sum(Row, Heading) ; check_product(Row, Heading).

% check_product(-List,+Heading)
% check_product(-List,-Heading)
% check_product(+List,-Heading)
% check_product(+List,+Heading)
% check_product/2 takes in a List and a Heading and checks if the product of the 
% elements in List is equal to Heading, using an accumulator.
check_product(List, Heading) :-
    check_product(List,1,Heading).
check_product([], Acc, Acc).
check_product([X|Xs], Acc, Heading) :-
    NewAcc #= Acc*X,
    check_product(Xs, NewAcc, Heading).

% check_sum(-List,+Heading)
% check_sum(-List,-Heading)
% check_sum(+List,-Heading)
% check_sum(+List,+Heading)
% check_sum/2 takes in a List and a Heading and checks if the sum of the 
% elements in List is equal to Heading, using an accumulator.
check_sum(List, Heading) :-
    check_sum(List,0,Heading).
check_sum([],Acc,Acc).
check_sum([X|Xs], Acc, Sum) :-
    NewAcc #= Acc+X,
    check_sum(Xs, NewAcc, Sum).

% ground_puzzle([_|+Rows])
% ground_puzzle([_|-Rows])
% ground_puzzle/1 takes in a Puzzle with the first row (Headings) removed and 
% checks that each value in Rows is ground.
ground_puzzle([_|Rows]) :- maplist(label, Rows).

