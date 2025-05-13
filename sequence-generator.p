neighbor_word(X, Y) :-
    maplist(string_chars, [X, Y], [XCs, YCs]),
    select(X_Letter, XCs, Y_Letter, YCs),
    X_Letter \= Y_Letter.

get_graph(File_Name, Graph) :-
    read_file_to_string(File_Name, Content, []),
    string_lines(Content, Words),
    findall(W1-W2, (
        member(W1, Words),
        member(W2, Words),
        neighbor_word(W1, W2)
        ), Edges),
    vertices_edges_to_ugraph([], Edges, Graph_Naive),
    vertices(Graph_Naive, Naive_Vertices),
    findall(Bad_Vertex, (
        member(Bad_Vertex, Naive_Vertices),
        reachable(Bad_Vertex, Graph_Naive, Reachables),
        length(Reachables, Too_Few),
        Too_Few < 15 % TODO magic value
        ), Bad_Vertices),
    del_vertices(Graph_Naive, Bad_Vertices, Graph).

build_sequence(Sequence_Backwards, _, 0, _, Sequence) :-
    !,
    reverse(Sequence_Backwards, Sequence).

% build_sequence([Last_Vertex|Earlier_Vertices], Graph, 1, _, Sequence) :- % adding last vertex: no restrictions (might even be the same as the start, or any other element!)
%     !,
%     neighbors(Last_Vertex, Graph, Final_Candidates),
%     member(Final_Choice, Final_Candidates),
%     reverse([Final_Choice, Last_Vertex|Earlier_Vertices], Sequence).

build_sequence([Last_Vertex|Earlier_Vertices], Graph, Vertices_To_Add, Banned_Vertices, Sequence) :-
    neighbors(Last_Vertex, Graph, Lax_Candidates),
    ord_subtract(Lax_Candidates, Banned_Vertices, Candidates),
    Vertices_To_Add_After is Vertices_To_Add - 1,
    ord_union(Banned_Vertices, Lax_Candidates, Banned_Vertices_After),
    member(Next_Choice, Candidates),
    build_sequence([Next_Choice, Last_Vertex|Earlier_Vertices], Graph, Vertices_To_Add_After, Banned_Vertices_After, Sequence).


sequence_from(Start_Vertex, Graph, Vertices_To_Add, Sequence) :-
    build_sequence([Start_Vertex], Graph, Vertices_To_Add, [Start_Vertex], Sequence).


get_sequence(Words_File_Name, S) :-
    get_graph(Words_File_Name, Graph),
    vertices(Graph, Vertices),
    member(Start_Vertex, Vertices),
    sequence_from(Start_Vertex, Graph, 14, S). % TODO magic value
