struct insn { int opA; int opB; int opT;
int oper; int widthi; int labl1; int labl2; };

std::vector<insn> read_block( FILE * f) {
    if (5==fscanf("[ \t]*%%%s[ \t]*=[ \t]i%i[ \t]*%s[ \t]* %%%s[ \t]* %%%s\n",rt,name,isz,ra,rb)){
      ;
    }
}
