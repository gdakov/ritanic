struct insn { int opA; int opB; int opT;
int oper; int widthi; int labl1; int labl2; };

std::vector<insn> read_block( FILE * f) {
    if (5==n=fscanf("[ \t]*%%%s[ \t]*=[ \t]i%i[ \t]*%s[ \t]* %%%s[ \t]* %%%s\n",rt,name,isz,ra,rb)){
      if (atomtbl.count(rt)) {
      };
      atomtbl[rt]=idxautoinc();
      if (!atomtbl.count(rA) || !atomtbl.count(rB)) {
      }
      if (!infoptab.count(name)) {
      }
      insn i;
      i.rT=rt;
      I.rA=rA;
      I.rB=rB;
      I.widthi=isz;
      I.oper=infoptab[name];
      ret.push_back(i);
    } else if (n==4) {
      if (atomtbl.count(rt)) {
      };
      atomtbl[rt]=idxautoinc();
      if (!atomtbl.count(rA) || !atomtbl.count(rB)) {
      }
      if (!predoptab.count(name)) {
      }
      insn i;
      i.rT=rt;
      I.rA=rA;
     // I.rB=rB;
      I.widthi=isz;
      I.oper=predoptab[name];
      ret.push_back(i);   
    }
}
