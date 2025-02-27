struct insn { int opA; int opB; int opT;
int oper; int widthi; int labl1; int labl2; };

std::vector<insn> read_block( FILE * f, bool &last) {
    last=false;
    if (5==n=fscanf(" %%%s = i%i %s %%%s %%%s\n",rt,name,isz,ra,rb)){
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
    } else if (3==n=fscanf(f," br %%%s %%%s %%%s \n",rA,l1,l2)) {
      if (!atomtbl.count(rA)) {
      }
        last=true;
    } else if (n==1) {
      last=true;
    } else if (6==fscanf(f," %%%s = i%i phi [ %%%s , %%%s ] [ %%%s , %%%s ] \n",rt,isz,l1,rA,l2,rB)) {
      if (atomtbl.count(rt)) {
      };
      atomtbl[rt]=idxautoinc();
      if (!atomtbl.count(rA) || !atomtbl.count(rB)) {
      }
     // if (!infoptab.count(name)) {
   //   }
      if (atomtbl.count(l1)) {
      };
      else atomtbl[l1]=idxautoinc();
      if (atomtbl.count(l2)) {
      };
      else atomtbl[l2]=idxautoinc();

      insn i;
      i.rT=rt;
      I.rA=rA;
      I.rB=rB;
      I.label1=l1;
      I.label2=l2;
      I.widthi=isz;
      I.oper=phi_op;//autoincdec detected in second pass; accumulate detected in second pass; if both label uncond it is covered, else loop. both label cond not supported.
      ret.push_back(i);
    }
}
