% PVR 20/07/92: Added entry declaration for move/5 (it is used in a bagof).

% ------------------------------------------------------------------------------
% Chess -- Mar. 1, 1987   Mike Carlton
%
% Adapted by Yu ("Tony") Zhang for ASU CSE 259, Fall 2019
% Modified by Waqar Hassan Khan for ASU CSE 259, Spring 2024
%
% Standard rules of chess apply with the following exceptions:
%  en passant captures are not allowed,
%  pawns are promoted to queens only,
%  draw by repetition or capture are not allowed,
%  kings may castle out of or through check (but not into).
%
% Files are numbered a to h, ranks are numbered 1 to 8,
% and white is assumed to play from the rank 1 side.
% The program always plays black.
%
% Positions are specified with the structure: File-Rank. 
% The board is a list containing two state structures of the form:
%  state(white, WhiteKing, WhiteKingRook, WhiteQueenRook), 
%  state(black, BlackKing, BlackKingRook, BlackQueenRook),
% followed by a list of the piece positions of the form: 
%  piece(File-Rank, Color, Type),
% where the state variables will be bound to an atom once the
% corresponding piece has been moved.
% A move is stored internally as: move(From_File-From_Rank, To_File-To_Rank).
%
% Commands available:
%  Move:  entered in the form FRFR (where F is in a..h and R is in 1..8)
%  board: prints the current board
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "PlayerA" PlayerA moves first (white);
% "PlayerB" PlayerB moves second (black);
%
% You should test with both PlayerA and PlayerB
%
% Competition will be based on the following parameters
%
%%%% IMPORTANT IMPORTANT IMPORTANT!!! MAKE SURE TO SET THESE SYSTEM VARIABLES
% THE FOLLOWING EXAMPLES ARE FOR bash
%-------------------------------------
% export LOCALSZ=284000
% export GLOBALSZ=1500000
% export TRAILSZ=284000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



/* this is the rule which we shall call from the console */
main :-
    randomize,                       % Setting up the seed for random number generator
    init_board(InBoard),
    play(InBoard),                   % Start playing
  fail.
main.



/* initial configuration of the chess board */
init_board([
  state(white, WhiteKing, WhiteKingRook, WhiteQueenRook),
  state(black, BlackKing, BlackKingRook, BlackQueenRook),
  piece(a-8, black, rook  ), piece(b-8, black, knight),
  piece(c-8, black, bishop), piece(d-8, black, queen ),
  piece(e-8, black, king  ), piece(f-8, black, bishop),
  piece(g-8, black, knight), piece(h-8, black, rook  ),
  piece(a-7, black, pawn  ), piece(b-7, black, pawn  ),
  piece(c-7, black, pawn  ), piece(d-7, black, pawn  ),
  piece(e-7, black, pawn  ), piece(f-7, black, pawn  ),
  piece(g-7, black, pawn  ), piece(h-7, black, pawn  ),
  piece(a-1, white, rook  ), piece(b-1, white, knight),
  piece(c-1, white, bishop), piece(d-1, white, queen ),
  piece(e-1, white, king  ), piece(f-1, white, bishop),
  piece(g-1, white, knight), piece(h-1, white, rook  ),
  piece(a-2, white, pawn  ), piece(b-2, white, pawn  ),
  piece(c-2, white, pawn  ), piece(d-2, white, pawn  ),
  piece(e-2, white, pawn  ), piece(f-2, white, pawn  ),
  piece(g-2, white, pawn  ), piece(h-2, white, pawn  )
]).



/* ----------------------------------------------------------------------- */
/* WRITE YOUR CODE FOR TASK-3 HERE */
/* Task 3: Autocomplete playerA and playerB */
play(Board) :-
    print_board(Board),
    % Move playerA automatically
    execute_command(playerA, Board, NewBoard),
    % Move playerB automatically
    execute_command(playerB, NewBoard, NextNewBoard),
    % Continue play recursively
    play(NextNewBoard).

/* Generate a move for playerA */
execute_command(playerA, Board, NewBoard) :-
    player(playerA, Color),
    opposite(Color, OppositeColor),
    strengthA(Board, Color, OppositeColor, _),
    ply_depthA(Depth),
    collect_movesA(Board, Color, Moves),
    member(Move, Moves),
    alpha_beta(playerA, Board, Color, Depth, -32000, 32000, Move, _),
    make_move(Board, Move, NewBoard), !.

/* Generate a move for playerB */
execute_command(playerB, Board, NewBoard) :-
    player(playerB, Color),
    opposite(Color, OppositeColor),
    strengthB(Board, Color, OppositeColor, _),
    ply_depthB(Depth),
    collect_movesB(Board, Color, Moves),
    member(Move, Moves),
    alpha_beta(playerB, Board, Color, Depth, -32000, 32000, Move, _),
    make_move(Board, Move, NewBoard), !.

/* Handle user moves */
execute_command(Move, Board, NewBoard) :-
    parse_move(Move, From, To),
    move(Board, From, To, white, _),
    make_move(Board, From, To, NewBoard), !.

/* Handle AI moves */
execute_command(Player, Board, NewBoard) :-
    respond_to(Player, Board, NewBoard), !.

/* Catch unexpected situations */
execute_command(_, _, _) :-
    write('What?'),
    halt(0).

/* Make move helper predicate */
make_move(Board, move(From, To), NewBoard) :-
    make_move(Board, From, To, NewBoard).

/* Alpha-beta helper predicate */
alpha_beta(Player, Board, Color, Depth, Alpha, Beta, Move, Val) :-
    alpha_beta(Player, Board, Color, Depth, Alpha, Beta, Move, Val).

/* ----------------------------------------------------------------------- */



/* getting command from the user so that playerA aka white can move */
get_command(Command) :-
    nl, write('white move -> '),
    read(Command), !.
  


/* execute the move selected */
execute_command(Move, Board, NewBoard) :-
         parse_move(Move, From, To),
         move(Board, From, To, white, _),
         make_move(Board, From, To, NewBoard), !.

execute_command(Player, Board, NewBoard) :-
    respond_to(Player, Board, NewBoard), !.

execute_command(_, _, _) :-     % Use to catch unexpected situations
    write('What?'),
    halt(0).



/* ----------------------------------------------------------------------- */
/* parameters */
noise_level(800).        % Noisy level to avoid livelock

player(playerA, white).
player(playerB, black).

/* -------------------------- DO NOT OVERRIDE --------------------------- */
strengthA([], _, _, Rand) :- noise_level(Level), random(0, Level, Number),
Rand is Number.               % Add random value to avoid deadlock
/* ----------------------------------------------------------------------- */



/* ----------------------------------------------------------------------- */
/* WRITE YOUR CODE FOR TASK-2 HERE */
% Color white for playerA, color black for playerB
% Skip state information in strength calculation
strengthA([state(_, _, _, _)|Board], Color, OppositeColor, Strength) :-
    strengthA(Board, Color, OppositeColor, Strength), !.

% Calculate strength for player pieces
strengthA([piece(_, Color, Type)|Board], Color, OppositeColor, Strength) :-
    valueA(Type, Value),
    strengthA(Board, Color, OppositeColor, PartialStrength),
    Strength is PartialStrength + Value, !.

% Calculate strength for opponent pieces
strengthA([piece(_, OppositeColor, Type)|Board], Color, OppositeColor, Strength) :-
    valueA(Type, Value),
    strengthA(Board, Color, OppositeColor, PartialStrength),
    Strength is PartialStrength - Value.

% Base case for empty board
strengthA([], _, _, 0).

% Define piece values for evaluation
valueA(king, 10000) :- !.
valueA(queen, 900) :- !.
valueA(rook, 500) :- !.
valueA(knight, 300) :- !.
valueA(bishop, 300) :- !.
valueA(pawn, 100) :- !.

% Set depth for alpha-beta search
ply_depthA(3).

% Book opening moves for playerA
bookA([state(white, _, _, _),
      state(black, _, _, _),
      piece(a-1, white, rook), piece(b-1, white, knight),
      piece(c-1, white, bishop), piece(d-1, white, queen),
      piece(e-1, white, king), piece(f-1, white, bishop),
      piece(g-1, white, knight), piece(h-1, white, rook),
      piece(a-2, white, pawn), piece(b-2, white, pawn),
      piece(c-2, white, pawn), piece(d-2, white, pawn),
      piece(e-2, white, pawn), piece(f-2, white, pawn),
      piece(g-2, white, pawn), piece(h-2, white, pawn),
      piece(a-8, black, rook), piece(b-8, black, knight),
      piece(c-8, black, bishop), piece(d-8, black, queen),
      piece(e-8, black, king), piece(f-8, black, bishop),
      piece(g-8, black, knight), piece(h-8, black, rook),
      piece(a-7, black, pawn), piece(b-7, black, pawn),
      piece(c-7, black, pawn), piece(d-7, black, pawn),
      piece(e-7, black, pawn), piece(f-7, black, pawn),
      piece(g-7, black, pawn), piece(h-7, black, pawn)], e-2, e-4).

% Alpha-beta pruning implementation
sufficientA(_, _, _, [], _, _, _, Move, Val, Move, Val) :- !.

sufficientA(Player, _, Turn, _, _, Alpha, _, Move, Val, Move, Val) :-
    Player \== Turn,
    Val < Alpha, !. % Pruning at MIN node

sufficientA(Player, _, Turn, _, _, _, Beta, Move, Val, Move, Val) :-
    Player = Turn,
    Val > Beta, !. % Pruning at MAX node

sufficientA(Player, Board, Turn, Moves, Depth, Alpha, Beta, Move, Val, BestMove, BestVal) :-
    new_bounds(Player, Turn, Alpha, Beta, Val, NewAlpha, NewBeta),
    find_best(Player, Board, Turn, Moves, Depth, NewAlpha, NewBeta, Move1, Val1),
    better_of(Player, Turn, Move, Val, Move1, Val1, BestMove, BestVal).

% Collect all legal moves for a given color
collect_movesA(Board, Color, Moves) :-
    bagof(move(From, To), Piece^move(Board, From, To, Color, Piece), Moves).
/* ----------------------------------------------------------------------- */



/* -------------------------- DO NOT OVERRIDE --------------------------- */
strengthB([], _, _, Rand) :- noise_level(Level), random(0, Level, Number),
      Rand is Number.               % Add random value to avoid deadlock
/* ----------------------------------------------------------------------- */



/* ----------------------------------------------------------------------- */
/* playerB Code */
% Strength assesses utility of the current game state for player based on its Color
% Color will be black for playerB; OppositeColor is playerA (white)
strengthB([state(_, _, _, _)|Board], Color, OppositeColor, Strength) :-
    strengthB(Board, Color, OppositeColor, Strength), !.
strengthB([piece(_, Color, Type)|Board], Color, OppositeColor, Strength) :-
    valueB(Type, Value),
    strengthB(Board, Color, OppositeColor, PartialStrength),
    Strength is PartialStrength + Value, !.
strengthB([piece(_, OppositeColor, Type)|Board], Color, OppositeColor,
      Strength) :-
    valueB(Type, Value),
    strengthB(Board, Color, OppositeColor, PartialStrength),
    Strength is PartialStrength - Value.


ply_depthB(3).          % Depth of alpha-beta search


% Define the utility function for playerB
% SUM of all pieces is smaller than 32000
valueB(king, 10000) :- ! .
valueB(queen,  900) :- ! .
valueB(rook,   500) :- ! .
valueB(knight, 300) :- ! .
valueB(bishop, 300) :- ! .
valueB(pawn,   100) :- ! .

% PlayerB book moves, black
bookB( [ state(white, WhiteKing, WhiteKingRook, WhiteQueenRook), % e2e4
    state(black, BlackKing, BlackKingRook, BlackQueenRook),
    piece(a-8, black, rook  ), piece(b-8, black, knight ),  
    piece(c-8, black, bishop), piece(d-8, black, queen ),
    piece(e-8, black, king  ), piece(f-8, black, bishop),
    piece(g-8, black, knight ), piece(h-8, black, rook  ),
    piece(a-7, black, pawn  ), piece(b-7, black, pawn  ),
    piece(c-7, black, pawn  ), piece(d-7, black, pawn  ),
    piece(e-7, black, pawn  ), piece(f-7, black, pawn  ),
    piece(g-7, black, pawn  ), piece(h-7, black, pawn  ),
    piece(a-1, white, rook  ), piece(b-1, white, knight ),
    piece(c-1, white, bishop), piece(d-1, white, queen ),
    piece(e-1, white, king  ), piece(f-1, white, bishop),
    piece(g-1, white, knight ), piece(h-1, white, rook  ),
    piece(a-2, white, pawn  ), piece(b-2, white, pawn  ),
    piece(c-2, white, pawn  ), piece(d-2, white, pawn  ),
    piece(f-2, white, pawn  ), piece(g-2, white, pawn  ),
    piece(h-2, white, pawn  ), piece(e-4, white, pawn  ) ], e-7, e-5).


% Code for alpha beta prunning
% Player is playerB, Turn is the player whose turn is to play
sufficientB(Player, Board, Turn, [], Depth, Alpha, Beta, Move, Val, Move, Val) :- !.
sufficientB(Player, Board, Turn, Moves, Depth, Alpha, Beta, Move, Val, Move, Val) :-
    Player \== Turn,        % It is the opponent turn to play, MIN node at Turn
    Val < Alpha, !.         % Pruning the branch since it is not useful
sufficientB(Player, Board, Turn, Moves, Depth, Alpha, Beta, Move, Val, Move, Val) :-
    Player = Turn,          % It is the Player turn to play, MAX node at Turn
    Val > Beta, !.          % Pruning the branch since it is not useful
sufficientB(Player, Board, Turn, Moves, Depth, Alpha, Beta, Move, Val,
    BestMove, BestVal) :-
    new_bounds(Player, Turn, Alpha, Beta, Val, NewAlpha, NewBeta),
    find_best(Player, Board, Turn, Moves, Depth, NewAlpha, NewBeta, Move1, Val1),
    better_of(Player, Turn, Move, Val, Move1, Val1, BestMove, BestVal).


% Code to collect moves given the current state Board
% If Moves is empty, it should return FAIL.
collect_movesB(Board, Color, Moves) :-
    bagof(move(From, To), Piece^move(Board,From,To,Color,Piece), Moves).



/* ----------------------------------------------------------------------- */
/* Chess procedures */
respond_to(Player, Board, OutBoard) :-
  write('Working...'), nl,
    % statistics,
  select_move(Player, Board, From, To, Rating),       % Select the next move
    % statistics,
  finish_move(Player, Board, From, To, Rating,        % Finish the next move
          OutBoard), !.


finish_move(Player, Board, From, To, -32000, Board) :-
  player(Player, Color),
  in_check(Board, Color),
    opposite(Player, Opponent),
    opposite(Color, OpponentColor),
  write('Checkmate, '),
    write(Opponent),
    write(' ('),
    write(OpponentColor),
    write(') won.'), nl,
    print_board(Board),
    abort.
finish_move(Player, Board, From, To, -32000, Board) :-
  write('Stalemate.'), nl,
  print_board(Board),
    abort.
finish_move(Player, NewBoard, From, To, Rating, OutBoard) :-
    player(Player, Color),
  make_move(NewBoard, From, To, OutBoard),
  report_move(Color, OutBoard, From, To, Rating).


select_move(Player, Board, From, To, bookA) :-    % Use book for playerA
    player(Player, white),
  bookA(Board, From, To), !.
select_move(Player, Board, From, To, bookB) :-    % Use book for playerB
    player(Player, black),
    bookB(Board, From, To), !.
select_move(Player, Board, From, To, Rating) :-    % time for ALPHA-BETA
    (player(Player, white) -> ply_depthA(Depth);ply_depthB(Depth)),
  alpha_beta(Player, Board, Player, Depth, -32000, 32000,
          move(From, To), Rating).


alpha_beta(Player, Board, Turn, 0, Alpha, Beta, BestMove, MoveVal) :-
  player(Player, Color),
  evaluate(Board, Color, MoveVal), !.
alpha_beta(Player, Board, Turn, Depth, Alpha, Beta, BestMove, MoveVal) :-
    player(Turn, Color),
    (player(Player, white) ->
  (collect_movesA(Board, Color, MoveList) ->     % Turn is the player whose turn is to play
        find_best(Player, Board, Turn, MoveList, Depth, Alpha, Beta,
              BestMove, MoveVal);
     MoveVal is -32000);             % If MoveList is empty, it means end of game or stalemate
    (collect_movesB(Board, Color, MoveList) ->     % Turn is the player whose turn is to play
        find_best(Player, Board, Turn, MoveList, Depth, Alpha, Beta,
              BestMove, MoveVal);
     MoveVal is -32000)).


find_best(Player, Board, Turn, [move(From, To)|Moves], Depth, Alpha, Beta,
    BestMove, BestVal) :-
  make_move(Board, From, To, NewBoard),
  NextDepth is Depth - 1,
  opposite(Turn, NextTurn),
  alpha_beta(Player, NewBoard, NextTurn, NextDepth, Alpha, Beta, _, Val),
    (player(Player, white)->
        sufficientA(Player, Board, Turn, Moves, Depth, Alpha, Beta,
            move(From,To), Val, BestMove, BestVal);
        sufficientB(Player, Board, Turn, Moves, Depth, Alpha, Beta,
            move(From,To), Val, BestMove, BestVal)).


new_bounds(Player, Turn, Alpha, Beta, Val, Val, Beta) :-
    Player = Turn,      % Maximizing, keep the larger value
  Val > Alpha, !.
new_bounds(Player, Turn, Alpha, Beta, Val, Alpha, Val) :-
    Player \== Turn,        % Minimizing, keep the samller value
  Val < Beta, !.
new_bounds(_, _, Alpha, Beta, _, Alpha, Beta).


better_of(Player, Turn, Move, Val, Move1, Val1, Move, Val) :-
    Player \== Turn,        % Minimizing, the smaller the better
  Val < Val1, !.
better_of(Player, Turn, Move, Val, Move1, Val1, Move, Val) :-
    Player = Turn,    % Maximizing, the greater the better
  Val > Val1, !.
better_of(_, _, _, _, Move1, Val1, Move1, Val1).


evaluate(Board, Color, Rating) :-
    \+ member(piece(_, Color, king), Board) -> Rating is -32000; % You do not want to lose the king
    opposite(Color, OppositeColor),
    (player(playerA, Color)->strengthA(Board, Color, OppositeColor, Rating);
    strengthB(Board, Color, OppositeColor, Rating)).


legal_move(Board, Color, From, To) :-
  move(Board, From, To, Color, Piece),
  make_move(Board, From, To, NewBoard), !,
  \+ in_check(NewBoard, Color).


in_check(Board, Color) :-
  mymember(piece(KingSquare, Color, king), Board),
  opposite(Color, OppositeColor),
  move(Board, _, KingSquare, OppositeColor, _).


make_move(Board, From, To, OutBoard) :-
  make_move(Board, From, To, Color, Type, NewBoard),    
  update_state(NewBoard, From, Color, Type),
  check_castling(NewBoard, From, To, Color, Type, OutBoard).
make_move([], From, File-8, white, pawn, [piece(File-8, white, queen)]).
make_move([], From, File-1, black, pawn, [piece(File-1, black, queen)]).
make_move([], From, To, Color, Type, [piece(To, Color, Type)]).     % Add To sq.
make_move([piece(From, Color, Type)|Board], From, To, Color, Type, OutBoard) :-
  make_move(Board, From, To, Color, Type, OutBoard).          % Skip From
make_move([piece(To, _, _)|Board], From, To, Color, Type, OutBoard) :-
  make_move(Board, From, To, Color, Type, OutBoard).          % Skip To sq
make_move([Piece|Board], From, To, Color, Type, [Piece|OutBoard]) :-
  make_move(Board, From, To, Color, Type, OutBoard).      % Copy


check_castling(Board, e-Rank, g-Rank, Color, king, OutBoard) :- % King side
  make_move(Board, h-Rank, f-Rank, OutBoard).    % castling
check_castling(Board, e-Rank, c-Rank, Color, king, OutBoard) :- % Queen side
  make_move(Board, a-Rank, d-Rank, OutBoard).    % castling
check_castling(Board, _, _, _, _, Board).

parse_square(Square, File-Rank) :-
    name(Square, [F,R]),
    name(File, [F]),
    myname(Rank, [R]),
    on_board(File-Rank).
 
parse_move(Move, From_File-From_Rank, To_File-To_Rank) :-
    name(Move, [FF,FR,TF,TR]),
    name(From_File, [FF]),
    myname(From_Rank, [FR]),
    name(To_File, [TF]),
    myname(To_Rank, [TR]),
    on_board(From_File-From_Rank),
    on_board(To_File-To_Rank).
 
on_board(File-Rank) :-
  mymember(File, [a, b, c, d, e, f, g, h]),
  mymember(Rank, [1, 2, 3, 4, 5, 6, 7, 8]).

not_moved(Board, Color, king) :-
  mymember(state(Color, King, _, _), Board), !,
  var(King).
not_moved(Board, Color, king, rook) :-
  mymember(state(Color, _, KingRook, _), Board), !,
  var(KingRook).
not_moved(Board, Color, queen, rook) :-
  mymember(state(Color, _, _, QueenRook), Board), !,
  var(QueenRook).

update_state(Board, From, Color, king) :-    % Was king moved?
  mymember(state(Color, king_moved, _, _), Board).
update_state(Board, h-Rank, Color, rook) :-    % Was king rook moved?
  mymember(state(Color, _, king_rook_moved, _), Board).
update_state(Board, a-Rank, Color, rook) :-    % Was queen rook moved?
  mymember(state(Color, _, _, queen_rook_moved), Board).
update_state(_, _, _, _).                       % Else, ignore



/* ----------------------------------------------------------------------- */
/* Printing utilities */
report_move(Color, Board, From_File-From_Rank, To_File-To_Rank, Rating) :-
  nl,
  write(Color),
  write(' move: '),
  write(From_File), 
  write(From_Rank),
  write(To_File),
  write(To_Rank),
  write(', Rating: '),
  write(Rating), nl,
  print_board(Board).


/* ----------------------------------------------------------------------- */
/* WRITE YOUR CODE FOR TASK-1 HERE */
print_board(Board) :-
    nl,
    write(' a b c d e f g h'), nl,
    write(' +-----------------+'), nl,
    print_ranks(Board, 8),
    write(' +-----------------+'), nl,
    write(' a b c d e f g h'), nl.

% Print each rank of the board
print_ranks(_, 0) :- !.
print_ranks(Board, Rank) :-
    write(Rank), write(' | '),
    print_files(Board, Rank, a),
    write('|'), nl,
    NextRank is Rank - 1,
    print_ranks(Board, NextRank).

% Print each file in a rank
print_files(_, _, i) :- !.
print_files(Board, Rank, File) :-
    print_piece(Board, File-Rank),
    next_file(File, NextFile),
    print_files(Board, Rank, NextFile).

% Print a single piece at the given square
print_piece(Board, Square) :-
    member(piece(Square, Color, Type), Board), !,
    piece_symbol(Color, Type, Symbol),
    write(Symbol), write(' ').
print_piece(_, _) :-
    write('. ').

% Define symbols for each piece type and color
piece_symbol(white, king, 'K').
piece_symbol(white, queen, 'Q').
piece_symbol(white, rook, 'R').
piece_symbol(white, bishop, 'B').
piece_symbol(white, knight, 'N').
piece_symbol(white, pawn, 'P').
piece_symbol(black, king, 'K*').
piece_symbol(black, queen, 'Q*').
piece_symbol(black, rook, 'R*').
piece_symbol(black, bishop, 'B*').
piece_symbol(black, knight, 'N*').
piece_symbol(black, pawn, 'P*').

% Define the sequence of files
next_file(a, b).
next_file(b, c).
next_file(c, d).
next_file(d, e).
next_file(e, f).
next_file(f, g).
next_file(g, h).
next_file(h, i).

/* ----------------------------------------------------------------------- */



/* ----------------------------------------------------------------------- */
/* more utilities */
myname(X,[Y]) :-
  myname2(Y, X), !.

myname2(48, 0).
myname2(49, 1).
myname2(50, 2).
myname2(51, 3).
myname2(52, 4).
myname2(53, 5).
myname2(54, 6).
myname2(55, 7).
myname2(56, 8).
myname2(57, 9).



/* ----------------------------------------------------------------------- */
/* Valid move checkers and generators */

move(Board, F_File-F_Rank, T_File-T_Rank, Color, Piece) :-
  occupied_by(Board, F_File-F_Rank, Color, Piece),
  can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, Piece),
  \+ occupied_by(Board, T_File-T_Rank, Color, _).


can_move(Board, File-F_Rank, File-T_Rank, white, pawn) :-       % White pawn 
  plus_one(F_Rank, T_Rank),        % move
  \+ occupied_by(Board, File-T_Rank, black, _).
can_move(Board, File-2, File-4, white, pawn) :-          
  \+ occupied_by(Board, File-3, black, _),
  \+ occupied_by(Board, File-4, black, _).
can_move(Board, F_File-F_Rank, T_File-T_Rank, white, pawn) :-   % White pawn 
  plus_one(F_File, T_File),        % capture
       plus_one(F_Rank, T_Rank),
  occupied_by(Board, T_File-T_Rank, black, _).
can_move(Board, F_File-F_Rank, T_File-T_Rank, white, pawn) :-  
  minus_one(F_File, T_File),      
       plus_one(F_Rank, T_Rank),
  occupied_by(Board, T_File-T_Rank, black, _).
can_move(Board, File-F_Rank, File-T_Rank, black, pawn) :-  % Black pawn 
  minus_one(F_Rank, T_Rank),        % move
  \+ occupied_by(Board, File-T_Rank, white, _).
can_move(Board, File-7, File-5, black, pawn) :-
  \+ occupied_by(Board, File-6, white, _),
  \+ occupied_by(Board, File-5, white, _).
can_move(Board, F_File-F_Rank, T_File-T_Rank, black, pawn) :-  % Black pawn 
  minus_one(F_File, T_File),        % capture
       minus_one(F_Rank, T_Rank),
  occupied_by(Board, T_File-T_Rank, white, _).
can_move(Board, F_File-F_Rank, T_File-T_Rank, black, pawn) :-
  plus_one(F_File, T_File),
       minus_one(F_Rank, T_Rank),
  occupied_by(Board, T_File-T_Rank, white, _).

can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-  % Knight move 
  plus_one(F_File, T_File), plus_two(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  plus_one(F_File, T_File), minus_two(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  minus_one(F_File, T_File), plus_two(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
   minus_one(F_File, T_File), minus_two(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  plus_two(F_File, T_File), plus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  plus_two(F_File, T_File), minus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  minus_two(F_File, T_File), plus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, knight) :-
  minus_two(F_File, T_File), minus_one(F_Rank, T_Rank).

can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, bishop) :- % Bishop move 
  can_step(Board,  1,  1, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, bishop) :-  
  can_step(Board,  1, -1, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, bishop) :-  
  can_step(Board, -1,  1, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, bishop) :-  
  can_step(Board, -1, -1, F_File-F_Rank, T_File-T_Rank).

can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, rook) :-  % Rook move 
  can_step(Board,  1,  0, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, rook) :-  
  can_step(Board, -1,  0, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, rook) :-  
  can_step(Board,  0,  1, F_File-F_Rank, T_File-T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, rook) :-  
  can_step(Board,  0, -1, F_File-F_Rank, T_File-T_Rank).

can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, queen) :-  % Queen move 
  can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, bishop).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, queen) :-  
  can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, rook).

can_move(Board, File-F_Rank, File-T_Rank, Color, king) :-  % King move 
  plus_one(F_Rank, T_Rank).
can_move(Board, File-F_Rank, File-T_Rank, Color, king) :-  
  minus_one(F_Rank, T_Rank).
can_move(Board, F_File-Rank, T_File-Rank, Color, king) :-  % King move 
  plus_one(F_File, T_File).
can_move(Board, F_File-Rank, T_File-Rank, Color, king) :-  
  minus_one(F_File, T_File).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, king) :-  
  plus_one(F_File, T_File),
  minus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, king) :-  
  plus_one(F_File, T_File),
  plus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, king) :-  
  minus_one(F_File, T_File),
  plus_one(F_Rank, T_Rank).
can_move(Board, F_File-F_Rank, T_File-T_Rank, Color, king) :-  
  minus_one(F_File, T_File),
  minus_one(F_Rank, T_Rank).

can_move(Board, e-Rank, g-Rank, Color, king) :-      % King side 
    not_moved(Board, Color, king),        % castle
    not_moved(Board, Color, king, rook),
  \+ occupied_by(Board, f-Rank, _, _).
can_move(Board, e-Rank, g-Rank, Color, king) :-      % Queen side 
    not_moved(Board, Color, king),        % castle
    not_moved(Board, Color, queen, rook),
  \+ occupied_by(Board, d-Rank, _, _),
  \+ occupied_by(Board, b-Rank, _, _).
 
can_step(Board,  1,  1, F_File-F_Rank, T_File-T_Rank) :-  % Step moves
  plus_one(F_File, T_File),
  plus_one(F_Rank, T_Rank).
can_step(Board,  1,  1, F_File-F_Rank, T_File-T_Rank) :-
  plus_one(F_File, I_File),
  plus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, I_File-I_Rank, _, _),
  can_step(Board,  1,  1, I_File-I_Rank, T_File-T_Rank).
can_step(Board,  1, 0, F_File-Rank, T_File-Rank) :-
  plus_one(F_File, T_File).
can_step(Board,  1, 0, F_File-Rank, T_File-Rank) :-
  plus_one(F_File, I_File),
  \+ occupied_by(Board, I_File-Rank, _, _),
  can_step(Board,  1, 0, I_File-Rank, T_File-Rank).
can_step(Board,  1, -1, F_File-F_Rank, T_File-T_Rank) :-
  plus_one(F_File, T_File),
  minus_one(F_Rank, T_Rank).
can_step(Board,  1, -1, F_File-F_Rank, T_File-T_Rank) :-
  plus_one(F_File, I_File),
  minus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, I_File-I_Rank, _, _),
  can_step(Board,  1, -1, I_File-I_Rank, T_File-T_Rank).
can_step(Board,  0,  1, File-F_Rank, File-T_Rank) :-
  plus_one(F_Rank, T_Rank).
can_step(Board,  0,  1, File-F_Rank, File-T_Rank) :-
  plus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, File-I_Rank, _, _),
  can_step(Board,  0,  1, File-I_Rank, File-T_Rank).
can_step(Board,  0, -1, File-F_Rank, File-T_Rank) :-
  minus_one(F_Rank, T_Rank).
can_step(Board,  0, -1, File-F_Rank, File-T_Rank) :-
  minus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, File-I_Rank, _, _),
  can_step(Board,  0, -1, File-I_Rank, File-T_Rank).
can_step(Board, -1,  1, F_File-F_Rank, T_File-T_Rank) :-
  minus_one(F_File, T_File),
  plus_one(F_Rank, T_Rank).
can_step(Board, -1,  1, F_File-F_Rank, T_File-T_Rank) :-
  minus_one(F_File, I_File),
  plus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, I_File-I_Rank, _, _),
  can_step(Board, -1,  1, I_File-I_Rank, T_File-T_Rank).
can_step(Board, -1,  0, F_File-Rank, T_File-Rank) :-
  minus_one(F_File, T_File).
can_step(Board, -1,  0, F_File-Rank, T_File-Rank) :-
  minus_one(F_File, I_File),
  \+ occupied_by(Board, I_File-Rank, _, _),
  can_step(Board, -1,  0, I_File-Rank, T_File-Rank).
can_step(Board, -1, -1, F_File-F_Rank, T_File-T_Rank) :-
  minus_one(F_File, T_File),
  minus_one(F_Rank, T_Rank).
can_step(Board, -1, -1, F_File-F_Rank, T_File-T_Rank) :-
  minus_one(F_File, I_File),
  minus_one(F_Rank, I_Rank),
  \+ occupied_by(Board, I_File-I_Rank, _, _),
  can_step(Board, -1, -1, I_File-I_Rank, T_File-T_Rank).


occupied_by(Board, File-Rank, Color, Piece) :-
  mymember(piece(File-Rank, Color, Piece), Board).


plus_one(1, 2).  
plus_one(2, 3).  
plus_one(3, 4).  
plus_one(4, 5).  
plus_one(5, 6).  
plus_one(6, 7).  
plus_one(7, 8).  

plus_one(a, b).
plus_one(b, c).
plus_one(c, d).
plus_one(d, e).
plus_one(e, f).
plus_one(f, g).
plus_one(g, h).

minus_one(X,Y) :-
  plus_one(Y, X).

plus_two(1, 3).  
plus_two(2, 4).  
plus_two(3, 5).  
plus_two(4, 6).  
plus_two(5, 7).  
plus_two(6, 8).  

plus_two(a, c).
plus_two(b, d).
plus_two(c, e).
plus_two(d, f).
plus_two(e, g).
plus_two(f, h).

minus_two(X,Y) :-
  plus_two(Y, X).


mymember(X, [X|_]).
mymember(X, [_|L]) :-
  mymember(X, L).

opposite(white, black).
opposite(black, white).

opposite(playerA, playerB).
opposite(playerB, playerA).
