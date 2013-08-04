### THIS PROGRAM CONTAINS AN IMPLEMENTATION OF THE
### TRANSMISSION-RELAXATION PROCEDURE OF DYNNIKOV-WIEST.  IT WAS
### WRITTEN BY MICHEL BONNEFONT AND ERWAN HILLION, USING ELEMENTS OF
### AN EARLIER PROGRAM FOR DRAWING CURVE DIAGRAMS BY JUAN
### GONZALEZ-MENESES. A BUG WAS LATER FIXED BY BERT WIEST.

# Functions defined in this file:
#
#   name            called by
#   ------------------------------------------------------
#   crossings       draw,touslesrect,transmrelax
#   diagram         draw
#   draw            transmrelax
#   petirond        touslesrect
#   grorond         touslesrect
#   touslesrect     transmrelax
#   tracerect       transmrelax
#   bonsens         neworder
#   rectordre       neworder
#   neworder        transmrelax
#   lexnum          transmission,relaxable,arel,relaxation
#   numlex          transmission,relaxation
#   transmission    transmrelax
#   relaxable       transmrelax
#   arel            transmrelax
#   cross           relaxation
#   relaxation      transmrelax
#   transmrelax     -
#   invers          -

lang := `english`:

with(plots):

if lang = `english` then
    mouvement_spirallant := `spiralling move`:
    le_diagramme_de_tresse_est := `The curve diagram of the braid is:`:
    les_rectangles_sont_maintenant := `The rectangles are now:`:
    apres_transmission_les_rectangles_sont := `After transmission the rectangles are:`:
    avant_de_pouvoir_relaxer_une_nouvelle_transmission_est_necessaire := `Before being able to relax, a new transmission is needed`:
    on_peut_alors_relaxer_par_la_tresse := `We can then relax using the braid `:
    de_longueur := ` with length `:
    le_nouveau_diagramme_de_tresse_est_maintenant := `The new curve diagram for the braid is now:`:
    la_longueur_totale_de_la_tresse_est := `The total length of the braid is:`:
    la_tresse_totale_utilisee_pour_demeler_est := `The total braid use to untangle is:`:
elif lang = `francais` then
    mouvement_spirallant := `mouvement spirallant`:
    le_diagramme_de_tresse_est := `Le diagramme de tresse est:`:
    les_rectangles_sont_maintenant := `Les rectangles sont maintenant:`:
    apres_transmission_les_rectangles_sont := `Apres transmission les rectangles sont:`:
    avant_de_pouvoir_relaxer_une_nouvelle_transmission_est_necessaire := `Avant de pouvoir relaxer, une nouvelle transmission est necessaire`:
    on_peut_alors_relaxer_par_la_tresse := `On peut alors relaxer par la tresse `:
    de_longueur := ` de longueur `:
    le_nouveau_diagramme_de_tresse_est_maintenant := `Le nouveau diagramme de tresse est maintenant:`:
    la_longueur_totale_de_la_tresse_est := `La longueur totale de la tresse est:`:
    la_tresse_totale_utilisee_pour_demeler_est := `La tresse totale utilisee pour demeler est:`:
else
    error "unknown language %1", lang
fi:


crossings:=proc(b,n)
local i,j,k,tot,K1,K2,K,counter,y2,l,t,circles,newcircles,y,d,u,p,x,join;
    for i from 1 to nops(b) do
        if b[i]<=-n or b[i]>=n then
            error "the indices of the letters must be smaller than n"
        fi;
        if b[i]=0 then
            error "the indices of the letters must be nonzero"
        fi;
    od;
    circles:=[[],[]];
    circles[1]:=[[0,0,seq(1,i=1..n-1),0],[seq(0,j=1..n+2)],seq([1,seq(0,j=1..n+1)],i=1..n-1),[seq(0,j=1..n+2)]];
    circles[2]:=[[0,0,seq(1,i=1..n-1),0],[seq(0,j=1..n+2)],seq([1,seq(0,j=1..n+1)],i=1..n-1),[seq(0,j=1..n+2)]];
    for i from 1 to nops(b) do
        if b[i]>0 then u:=1: d:=2: p:=b[i]: else u:=2: d:=1: p:=-b[i]:
        fi:
        newcircles:=circles:
        for j from 1 to n+2 do
            x:=circles[u][p+2][j]:
            if j<>p+2 and j<>p+3 and x>0 then
                newcircles[u][j][p+2]:=newcircles[u][j][p+2]-x:
                newcircles[u][p+2][j]:=newcircles[u][p+2][j]-x:
                newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]+x:
                newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]+x:
                newcircles[u][j][p+3]:=newcircles[u][j][p+3]+x:
                newcircles[u][p+3][j]:=newcircles[u][p+3][j]+x:
                newcircles[d][p+2][p+3]:=newcircles[d][p+2][p+3]+x:
                newcircles[d][p+3][p+2]:=newcircles[d][p+3][p+2]+x:
            fi;
            if j=p+3 and x>0 then
                newcircles[u][p+2][p+3]:=newcircles[u][p+2][p+3]-x:
                newcircles[u][p+3][p+2]:=newcircles[u][p+3][p+2]-x:
                newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]+x:
                newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]+x:
            fi;
            y:=circles[d][p+2][j]:
            if j<>p+2 and y>0 then
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]-y:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]-y:
                newcircles[d][p+1][j]:=newcircles[d][p+1][j]+y:
                newcircles[d][j][p+1]:=newcircles[d][j][p+1]+y:
            fi;
        od;
        K:=circles[u][p+2][p+3]:
        counter:=0:
        for j from p+1 to 1 by -1 do
            y:=circles[d][p+3][j]:
            if y>0 and counter<K then
                y2:=min(y,K-counter):
                newcircles[d][p+3][j]:=newcircles[d][p+3][j]-y2:
                newcircles[d][j][p+3]:=newcircles[d][j][p+3]-y2:
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]+y2:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]+y2:
                counter:=counter+y2:
            fi;
        od;
        for j from n+2 to p+4 by -1 do
            y:=circles[d][p+3][j]:
            if y>0 and counter<K then
                y2:=min(y,K-counter):
                newcircles[d][p+3][j]:=newcircles[d][p+3][j]-y2:
                newcircles[d][j][p+3]:=newcircles[d][j][p+3]-y2:
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]+y2:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]+y2:
                counter:=counter+y2:
            fi;
        od;
        x:=newcircles[d][p+1][p+1]/2:
        if x>0 then
            join:=[seq(0,k=1..n+2)]:
            y:=0:
            for j from p+3 to n+2 do
                if sum(join[l],l=1..n+2)<x then
                    join[j]:=min(circles[u][p+1][j],x-sum(join[l],l=1..n+2)):
                else break:
                fi;
            od;
            if sum(join[l],l=1..n+2)<x then
                for j from 1 to p do
                    if sum(join[l],l=1..n+2)<x then
                        join[j]:=min(circles[u][p+1][j],x-sum(join[l],l=1..n+2)):
                    else break:
                    fi;
                od;
            fi;
            newcircles[d][p+1][p+1]:=0:
            for j from 1 to n+2 do
                if join[j]>0 then
                    newcircles[u][j][p+1]:=newcircles[u][j][p+1]-join[j]:
                    newcircles[u][p+1][j]:=newcircles[u][p+1][j]-join[j]:
                    newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]-join[j]:
                    newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]-join[j]:
                    newcircles[u][j][p+2]:=newcircles[u][j][p+2]+join[j]:
                    newcircles[u][p+2][j]:=newcircles[u][p+2][j]+join[j]:
                fi;
            od;
        fi;
        circles:=newcircles;
    od;
    return circles;
end:

diagram:=proc(c)
local i,j,k,r,x,y,n,t,left,right,counterx,countery,circup,circdown,centr,radius,total;
    n:=nops(c[1])-2:
    total:=0:
    r:=[seq(0,i=1..n+2)]:
    for i from 1 to n+2 do
        r[i]:=sum(c[1][i][k],k=1..n+2)+1:
        for j from 1 to n+2 do
            total:=total+c[1][i][j]:
        od:
    od:
    total:=total/2:
    counterx:=0;
    countery:=0;
    circup:=array(1..total):
    circdown:=array(1..total):
    for i from 1 to n+1 do
        for j from i+1 to n+2 do
            x:=c[1][i][j];
            y:=c[2][i][j];
            if x>0 then
                left:=sum(c[1][i][l],l=i+1..j-1):
                right:=sum(c[1][j][l],l=i+1..j-1):
                for k from 1 to x do
                    centr:=((i-1-(left+k)/r[i])+(j-2+(right+k)/r[j]))/2:
                    radius:=centr-(i-1-(left+k)/r[i]):
                    circup[counterx+k]:=plot([centr+radius*cos(t),radius*sin(t),t=0..Pi]);
                od;
                counterx:=counterx+x;
            fi;
            if y>0 then
                left:=sum(c[2][i][l],l=i+1..j-1):
                right:=sum(c[2][j][l],l=i+1..j-1):
                for k from 1 to y do
                    centr:=((i-1-(left+k)/r[i])+(j-2+(right+k)/r[j]))/2:
                    radius:=centr-(i-1-(left+k)/r[i]):
                    circdown[countery+k]:=plot([centr+radius*cos(t),radius*sin(t),t=Pi..2*Pi]):
                od;
                countery:=countery+y;
            fi;
        od;
    od;
    print(display({seq(circup[i],i=1..counterx),seq(circdown[i],i=1..countery)},scaling=constrained));
    return:
end:

### Type "draw([1,-2,1],3);" in order to see the curve diagram of the
### 3-strand braid sigma_1 sigma_2^{-1} sigma_1
draw:=proc(a,b)
    return diagram(crossings(a,b));
end:

petirond := proc(c)
local i,j,k,e,f,A,B,L,n :
    n := nops(c[1][1])-2 :
    L := NULL :
    for i from 1 to n+2 do
        k:=1+sum('c[2][i][l]','l'=1..i) ;
        for j from n+2 to i+1 by -1 do
            if c[2][i][j]>0 then
                f:=c[2][i][j] ; e:=sum('c[2][j][l]','l'=i+1..j) ;
                A:=[[i,k],[i,k+f-1]] ; B:=[[j,1+e],[j,f+e]] ;
                k := k+f ;
                L := L,[[A,B],-1] ;
            fi ;
        od;
    od;

    return [L];

end:

grorond := proc(L,c)
local i,j,k,m,n,recol ,g,h, V;
    m := nops(L) ;
    n := nops(c[1])-2 ;
    recol:=[seq(0,i=1..m)] ;
    for i from 1 to m-1 do

        if L[i][1][2][1][1]>1 then

            if L[i][1][2][1][2]>1
            then
                if L[i][1][2][1]=L[i+1][1][2][2]+[0,1] then
                    recol[i]:=1 ;
                fi;
            else g:=round(L[i+1][1][2][2][1]); h:=eval(sum('c[1][g][j]','j=1..n+2'));
                if
                L[i][1][2][1]=L[i+1][1][2][2]+[1,1-h] then
                    recol[i]:=1 ;
                fi;
            fi;

        fi;
    od;

    V:=NULL:
    j:=1;
    while j <= m do
        if recol[j]=0
        then V := V,L[j] :
        else k:=j :
            while recol[j]=1 do
                j:=j+1 od :
            V:=V,[[[L[k][1][1][1],L[j][1][1][2]],[L[j][1][2][1],L[k][1][2][2]]],-1] :
        fi;
        j:=j+1:
    od;
    return V;
end:

touslesrect := proc(b,n)
### THERE WAS A BUG IN THE ORIGINAL PROGRAM - THE SUMMARIZING OF ARCS
### INTO BANDS WENT WRONG, BUT ONLY IN THE UPPER HALF.  BERT WIEST
### CORRECTED THIS BUG IN AN AWFULLY HACKY WAY, BY GLUING TOGETHER THE
### LOWER HALF OF THE TRUE BRAID WITH THE REFLECTION OF THE LOWER HALF
### OF THE BRAID WHERE ALL CROSSINGS ARE REPLACED BY THEIR NEGATIVE.
local P,c,c2,m,j :
    c := crossings(b,n) ;
    c2 := crossings(b*(-1),n);m := nops([grorond(petirond(c2),c2)]);
    P := grorond(petirond(c2),c2),grorond(petirond(c),c);
### for j from 1 to m do       THIS DOESN'T WORK, I (B.W.) DON'T UNDERSTAND WHY)
###   P[j][2] := 1;
### od;
    return [P],m;
end:

tracerect := proc(c,L)
local n,m,i,j,k,q,P,Q,R,S,rect,inter,nbsegrect,pt1,pt2,pt3,pt4,ray1,ray2,T,centre1,centre2,A,B,E,C,epsilon ;

    n:=nops(c[1])-2;
    m := nops(L) ;
    inter := array[1..n+2] ;
    for j from 1 to n+2 do
        inter[j] := sum('c[1][j][l]','l'=1..n+2)+1 ;
    od;

    for i from 1 to m do
        rect := L[i] :
        nbsegrect[i] := nops(rect[1]);

        epsilon := rect[2];
        for k from 1 to nbsegrect[i]-1 do

            if rect[1][k][1][1]<rect[1][k+1][1][1] then
                A:=rect[1][k];
                B:=rect[1][k+1];
            else
                B:=rect[1][k];
                A:=rect[1][k+1];
            fi;

            E:=epsilon*(-1)^(k+1);

            pt1:=A[1][1]-2+A[1][2]/inter[A[1][1]];
            pt2:=B[2][1]-2+B[2][2]/inter[B[2][1]];
            pt3:=A[2][1]-2+A[2][2]/inter[A[2][1]];
            pt4:=B[1][1]-2+B[1][2]/inter[B[1][1]];

            ray1:=(pt2-pt1)/2;
            ray2:=(pt4-pt3)/2;
            centre1:=(pt2+pt1)/2;
            centre2:=(pt3+pt4)/2;

            P[i][k] := plot([centre1+ray1*cos(E*t),ray1*sin(E*t),t=eval(0.03/ray1)..eval(Pi-0.03/ray1)]):
            Q[i][k] := plot([centre2+ray2*cos(E*t),ray2*sin(E*t),t=eval(0.03/ray2)..eval(Pi-0.03/ray2)]):
        od:


        A:=rect[1][1] : B:=rect[1][eval(nbsegrect[i])]:
        pt1:=A[1][1]-2+A[1][2]/inter[A[1][1]];
        pt2:=B[2][1]-2+B[2][2]/inter[B[2][1]];
        pt3:=A[2][1]-2+A[2][2]/inter[A[2][1]];
        pt4:=B[1][1]-2+B[1][2]/inter[B[1][1]];

        if (pt3>pt1) and (pt2>pt4) then
            R[i] := plot([t,eval(L[i][2])*0.03,t=pt1..pt3]):
            S[i] := plot([t,eval(L[i][2])*(-1)^(nbsegrect[i])*0.03,t=pt4..pt2]):
        else
            R[i] := plot([t,eval(L[i][2])*0.03,t=pt1-0.02..pt1+0.02]):
            S[i] := plot([t,eval(L[i][2])*(-1)^(nbsegrect[i])*0.03,t=pt2-0.02..pt2+0.02]):
        fi;

    od:
    A := NULL ;
    for i from 1 to m do
        for k from 1 to nbsegrect[i]-1 do
            A:=A,[P[i][k],Q[i][k]]:
        od:
        A:=A,[R[i],S[i]]
    od:
    display(A,scaling=constrained);
end:

bonsens := proc(R)
local m, epsilon,i,RR:
    m := nops(R[1]):
    epsilon := 1 ;
    RR := R ;
    if R[1][1][1][1]>R[1][m][1][1]
    then epsilon := -1
    fi;
    if (R[1][1][1][1]=R[1][m][1][1]) and (R[1][1][1][2]>R[1][m][1][2])
    then epsilon := -1;
    fi;

    if epsilon = -1 then
        for i from 1 to m do
            RR[1][i] := R[1][m-i+1];
        od:

        RR[2]:=R[2]*(-1)^m ;

    fi:
    return RR;
end:

rectordre := proc(R,T)
local mr,mt,reponse  :
    mr:= nops(R[1]) : mt:=nops(T[1]) :
    reponse := 0 :
    if R[1][mr][2][1]>T[1][mt][2][1]
    then reponse:=1  fi;

    if R[1][mr][2][1]=T[1][mt][2][1]
    then
        if R[1][mr][2][2]>T[1][mt][2][2]
        then reponse := 1 fi;

        if R[1][mr][2][2]=T[1][mt][2][2]
        then
            if R[1][mr][1][1]<T[1][mt][1][1]
            then reponse:=1 fi;

            if R[1][mr][1][1]=T[1][mt][1][1]
            then
                if R[1][mr][1][2]<T[1][mt][1][2]
                then reponse:=1 fi;

                if R[1][mr][1][2]=T[1][mt][1][2]
                then
                    if R[2]=1 then reponse:=1 fi;

                fi;

            fi;
        fi;
    fi;

    return reponse;
end:

neworder := proc(L)
local i,k,LL,m,j,P :
    m := nops(L) :
    LL := array[1..m] :

    for i from 1 to m do
        LL[i]:=bonsens(L[i]) :
    od:
    for j from 0 to m-2 do
        P := LL[1] :
        k:=1:
        for i from 2 to m-j do
            if  rectordre(P,LL[i])=0 then P:=LL[i] :
                k:=i fi:
        od:
        LL[k]:=LL[m-j]:
        LL[m-j]:=P:

    od:
    return [seq(LL[i],i=1..m)];
end:

lexnum:=proc(pt,c)
local i,num,n:

    n:=nops(c[1])-2:
    num:=0:
    for i from 1 to eval(pt[1])-1 do
        num:=num+eval(sum('c[1][i][k]','k'=1..n+2)):
    od:
    num:=num+pt[2]:
    return num;
end:

numlex:=proc(nb,c)
local i,k,n,A,m:
    k:=1:
    n:=nops(c[1])-2:
    A:=array[1..n+2]:
    for i from 1 to n+2 do
        A[i]:=eval(sum('c[1][i][k]','k'=1..n+2)) :
    od:
    while (k<n+3) and (nb-eval(sum('A[i]','i'=1..k))>0) do
        k:=k+1:
    od:
    k:=k :
    m:=nb-eval(sum('A[i]','i'=1..k-1)) :
    return [k,m];
end:

transmission:=proc(L,c)
local H,g,h,a,b,aa,bb,k,l,m,i,j,AB,Ab,u,v,uu,vv,Segp,Segv,compteur,larg,LL,LLL:
    m:=nops(L);
    H:=L[m]:
    g:=lexnum(H[1][eval(nops(H[1]))][1],c):
    h:=lexnum(H[1][eval(nops(H[1]))][2],c):
    LL:=L:
    LLL:=L:
    i:=m-1:
    l:=0:

    if m>1 then
        while (i>0) and (lexnum(L[i][1][eval(nops(L[i][1]))][1],c)>=g) do
            Segp := NULL : Segv := NULL:
            compteur:=0:
            AB:=L[i][1][eval(nops(L[i][1]))]:
            aa:=lexnum(AB[1],c):
            bb:=lexnum(AB[2],c):

            Ab:=L[i][1][1]:
            a:=lexnum(Ab[1],c):
            b:=lexnum(Ab[2],c):

            k:=eval(nops(H[1]))-1:
            while (aa>=g)and(bb<=h) do
                l:=l+bb-aa+1:
                for j from k to 1 by -1 do
                    if modp(k-j,2)=0
                    then
                        uu:=lexnum(H[1][j][1],c)+h-bb:
                        vv:=lexnum(H[1][j][1],c)+h-aa:

                    else
                        uu:=lexnum(H[1][j][2],c)-(h-aa):
                        vv:=lexnum(H[1][j][2],c)-(h-bb):
                    fi;
                    Segp:=Segp,[numlex(uu,c),numlex(vv,c)]:
                od:
                aa:=uu:
                bb:=vv:
            od:

            while (a>=g)and(b<=h) do
                l:=l+b-a+1:
                for j from k to 1 by -1 do
                    if modp(k-j,2)=0
                    then
                        u:=lexnum(H[1][j][1],c)+h-b:
                        v:=lexnum(H[1][j][1],c)+h-a:

                    else
                        u:=lexnum(H[1][j][2],c)-(h-a):
                        v:=lexnum(H[1][j][2],c)-(h-b):
                    fi:
                    Segv:=[numlex(u,c),numlex(v,c)],Segv:
                od:
                a:=u:
                b:=v:
                compteur:=compteur+1:
            od:


            LL[i]:=[[Segv,op(L[i][1]),Segp],eval(L[i][2])*(-1)^(compteur*k)]:
            i:=i-1:
        od:



        larg:=h-g-l:

        if larg<0 then LLL:=[seq(LL[i],i=1..m-1)]
        else for j from k+1 to 1 by -1 do
                 if modp(k+1-j,2)=0
                 then H[1][j]:=[H[1][j][1],numlex(lexnum(H[1][j][1],c)+larg,c)]
                 else H[1][j]:=[numlex(lexnum(H[1][j][2],c)-larg,c),H[1][j][2]]
                 fi:
             od:
            LLL:=[seq(LL[i],i=1..m-1),H]
        fi:
    fi;
    return LLL;
end:

relaxable := proc(L,c)
local m,i,j,k,n,mmaaxx,ind,IND ;
    n := nops(L) ;
    ind := NULL ;
    IND:=NULL;
    m := array[1..n] ;
    for i from 1 to n do
        m[i] := nops(L[i][1]) :
        if m[i]>=4 then ind:=ind,i fi:
    od:
    ind := [ind]:

    for k from 1 to nops(ind) do

        for j from 2 to m[eval(ind[k])]-1 do
            if lexnum(L[eval(ind[k])][1][j][2],c)+1=lexnum(L[eval(ind[k])][1][j+1][1],c)
            then IND:=[ind[k],j,1,lexnum(L[eval(ind[k])][1][j][2],c)+1],IND
            fi;

            if lexnum(L[eval(ind[k])][1][j+1][2],c)+1=lexnum(L[eval(ind[k])][1][j][1],c)
            then IND:=[ind[k],j,-1,lexnum(L[eval(ind[k])][1][j+1][2],c)+1],IND
            fi;

        od;
    od;IND:=[IND]:
    if nops(IND)>0
    then mmaaxx:=1;
        for i from 1 to eval(nops(IND)) do
            if IND[i][4]>=IND[mmaaxx][4] then mmaaxx:=i fi;
        od;
        return IND[mmaaxx];
    else return IND;
    fi;
end:

arel:=proc(IND,L,c,showsteps)
local i,j,LL,IN,IN1,d,g,Tr,k;
    IN:=IND:
    IN1:=IND[1]:
    Tr:=0:
    LL:=L:
    for i from 1 to nops(L) do
        for j from 1 to nops(L[i][1]) do
            LL[i][1][j][1]:=lexnum(L[i][1][j][1],c):
            LL[i][1][j][2]:=lexnum(L[i][1][j][2],c)
        od;
    od;

    if IN[3]=1  then g:=LL[IN[1]][1][IN[2]][1]:
        d:=LL[IN[1]][1][IN[2]+1][2]
    else g:=LL[IN[1]][1][IN[2]+1][1]:
        d:=LL[IN[1]][1][IN[2]][2]
    fi;

    k:=1:
    while k=1 do
        k:=0:
        for i from 1 to nops(LL) do
            for j from 1 to nops(LL[i][1])-1 do
                if (LL[i][1][j][2]=g-1) and (LL[i][1][j+1][1]=d+1)
                then   if i=IN1 then if showsteps then print(mouvement_spirallant) fi;
                       else k:=1:
                           g:=LL[i][1][j][1]:
                           d:=LL[i][1][j+1][2]:
                           IN:=IN,[i,j,1]:
                           IN1:=i:
                           if (j=1) or (j=nops(LL[i][1])-1) then Tr:=1 fi;
                       fi;
                fi;
                if (LL[i][1][j+1][2]=g-1) and (LL[i][1][j][1]=d+1)
                then  if i=IN1 then if showsteps then print(mouvement_spirallant) fi;
                      else k:=1:
                          g:=LL[i][1][j+1][1]:
                          d:=LL[i][1][j][2]:
                          IN:=IN,[i,j,-1]:
                          IN1:=i:
                          if (j=1) or (j=nops(LL[i][1])-1) then Tr:=1 fi;
                      fi;
                fi;
            od;
        od;
    od;
    return [IN],Tr
end:

cross:=proc(c,b,n)
local circles,newcircles,i,j,k,l,K,join,counter,x,y,y2,cc,u,d,p;
    circles:=c;
    for i from 1 to nops(b) do
        if b[i]>0 then u:=1: d:=2: p:=b[i]: else u:=2: d:=1: p:=-b[i]:
        fi:
        newcircles:=circles:
        for j from 1 to n+2 do
            x:=circles[u][p+2][j]:
            if j<>p+2 and j<>p+3 and x>0 then
                newcircles[u][j][p+2]:=newcircles[u][j][p+2]-x:
                newcircles[u][p+2][j]:=newcircles[u][p+2][j]-x:
                newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]+x:
                newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]+x:
                newcircles[u][j][p+3]:=newcircles[u][j][p+3]+x:
                newcircles[u][p+3][j]:=newcircles[u][p+3][j]+x:
                newcircles[d][p+2][p+3]:=newcircles[d][p+2][p+3]+x:
                newcircles[d][p+3][p+2]:=newcircles[d][p+3][p+2]+x:
            fi;
            if j=p+3 and x>0 then
                newcircles[u][p+2][p+3]:=newcircles[u][p+2][p+3]-x:
                newcircles[u][p+3][p+2]:=newcircles[u][p+3][p+2]-x:
                newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]+x:
                newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]+x:
            fi;
            y:=circles[d][p+2][j]:
            if j<>p+2 and y>0 then
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]-y:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]-y:
                newcircles[d][p+1][j]:=newcircles[d][p+1][j]+y:
                newcircles[d][j][p+1]:=newcircles[d][j][p+1]+y:
            fi;
        od;
        K:=circles[u][p+2][p+3]:
        counter:=0:
        for j from p+1 to 1 by -1 do
            y:=circles[d][p+3][j]:
            if y>0 and counter<K then
                y2:=min(y,K-counter):
                newcircles[d][p+3][j]:=newcircles[d][p+3][j]-y2:
                newcircles[d][j][p+3]:=newcircles[d][j][p+3]-y2:
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]+y2:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]+y2:
                counter:=counter+y2:
            fi;
        od;
        for j from n+2 to p+4 by -1 do
            y:=circles[d][p+3][j]:
            if y>0 and counter<K then
                y2:=min(y,K-counter):
                newcircles[d][p+3][j]:=newcircles[d][p+3][j]-y2:
                newcircles[d][j][p+3]:=newcircles[d][j][p+3]-y2:
                newcircles[d][p+2][j]:=newcircles[d][p+2][j]+y2:
                newcircles[d][j][p+2]:=newcircles[d][j][p+2]+y2:
                counter:=counter+y2:
            fi;
        od;
        x:=newcircles[d][p+1][p+1]/2:
        if x>0 then
            join:=[seq(0,k=1..n+2)]:
            y:=0:
            for j from p+3 to n+2 do
                if sum(join[l],l=1..n+2)<x then
                    join[j]:=min(circles[u][p+1][j],x-sum(join[l],l=1..n+2)):
                else break:
                fi;
            od;
            if sum(join[l],l=1..n+2)<x then
                for j from 1 to p do
                    if sum(join[l],l=1..n+2)<x then
                        join[j]:=min(circles[u][p+1][j],x-sum(join[l],l=1..n+2)):
                    else break:
                    fi;
                od;
            fi;
            newcircles[d][p+1][p+1]:=0:
            for j from 1 to n+2 do
                if join[j]>0 then
                    newcircles[u][j][p+1]:=newcircles[u][j][p+1]-join[j]:
                    newcircles[u][p+1][j]:=newcircles[u][p+1][j]-join[j]:
                    newcircles[u][p+1][p+2]:=newcircles[u][p+1][p+2]-join[j]:
                    newcircles[u][p+2][p+1]:=newcircles[u][p+2][p+1]-join[j]:
                    newcircles[u][j][p+2]:=newcircles[u][j][p+2]+join[j]:
                    newcircles[u][p+2][j]:=newcircles[u][p+2][j]+join[j]:
                fi;
            od;
        fi;
        circles:=newcircles;
    od;
    return circles;
end:

relaxation:=proc(L,IND,c)

local i,j,ni,k,l,m,IN,n,maxi,nbfil,NBFIL,LL,b,bb,pta,ptd,e,epsilon,circles,cc,newcircles,u,d,p,x,y,K,join,counter,y2;
    IN:=IND:
    LL:=L:
    for i from 1 to nops(LL) do
        for j from 1 to nops(LL[i][1]) do
            LL[i][1][j][1]:=lexnum(LL[i][1][j][1],c):
            LL[i][1][j][2]:=lexnum(LL[i][1][j][2],c)
        od;
    od;
    bb:=NULL:
    ni:=nops(IND):
    epsilon:=L[IN[1][1]][2]*(-1)^(IN[1][2]):

    NBFIL:=0:
    K:=0:

    if IN[ni][3]=1 then e:=1 else e:=0 fi:
    ptd:=L[IN[ni][1]][1][IN[ni][2]+e][2][1]-2:
    nbfil:=LL[IN[ni][1]][1][1][2]-LL[IN[ni][1]][1][1][1]+1:
    NBFIL:=NBFIL+nbfil:
    maxi:=LL[IN[ni][1]][1][IN[ni][2]+e][2];

    if nbfil>1 then
        for j from nbfil-1 to 1 by -1 do

            if numlex (j+LL[IN[ni][1]][1][IN[ni][2]+e][1],c)[1]
            >numlex (j+LL[IN[ni][1]][1][IN[ni][2]+e][1]-1,c)[1]
            then

                k:=LL[IN[ni][1]][1][IN[ni][2]-1+3*e][1]+nbfil-j:
                pta:=numlex(k,c)[1]-1+K:
                K:=K+1:

                if pta=0 then error "pta = 0": return 'A'; fi:
                if pta<ptd then for l from ptd-1 to pta by -1 do
                                    bb:=bb,-epsilon*l
                                od;
                else error "pta >= ptd (pta = %1, ptd = %2)", pta, ptd
                fi;
            fi;
        od;fi;


    if ni>1 then
        for i from ni-1 to 1 by -1 do
            nbfil:=LL[IN[i][1]][1][1][2]-LL[IN[i][1]][1][1][1]+1:
            NBFIL:=NBFIL+nbfil:

            if IN[i][3]=1 then e:=1 else e:=0 fi:

            for j from nbfil to 1 by -1 do
                if numlex (j+LL[IN[i][1]][1][IN[i][2]+e][1],c)[1]
                >numlex (j+LL[IN[i][1]][1][IN[i][2]+e][1]-1,c)[1]
                then

                    k:=LL[IN[i][1]][1][IN[i][2]-1+3*e][1]+nbfil-j:
                    pta:=numlex(k,c)[1]-1+K:
                    K:=K+1:

                    if pta=0 then error "pta = 0": return 'A'; fi:
                    if pta<ptd then for l from ptd-1 to pta by -1 do
                                        bb:=bb,-epsilon*l
                                    od;
                    else error "pta >= ptd (pta = %1, ptd = %2)", pta, ptd
                    fi;
                fi;
            od;
        od;fi;



    for i from 1 to ni do
        if IN[i][3]=1 then e:=0 else e:=1 fi:
        nbfil:=LL[IN[i][1]][1][1][2]-LL[IN[i][1]][1][1][1]+1:

        for j from nbfil to 1 by -1 do
            if numlex (j+LL[IN[i][1]][1][IN[i][2]+e][1],c)[1]
            >numlex (j+LL[IN[i][1]][1][IN[i][2]+e][1]-1,c)[1]
            then

                k:=LL[IN[i][1]][1][IN[i][2]-1+3*e][1]+nbfil-j:
                pta:=numlex(k,c)[1]-1+K:
                K:=K+1:

                if pta=0 then error "pta = 0": return 'A'; fi:
                if pta<ptd then for l from ptd-1 to pta by -1 do
                                    bb:=bb,-epsilon*l
                                od;
                else error "pta >= ptd (pta = %1, ptd = %2)", pta, ptd
                fi;
            fi;
        od;
    od;

    for m from 1 to ni do
        LL[IN[m][1]][1]:=[seq(LL[IN[m][1]][1][p],p=1..eval(IN[m][2])-1),
                          seq(LL[IN[m][1]][1][p],p=eval(IN[m][2])+2..nops(LL[IN[m][1]][1]))]
    od;


    for i from 1 to nops(LL) do
        for j from 1 to nops(LL[i][1]) do
            if LL[i][1][j][1]>maxi then LL[i][1][j][1]:=LL[i][1][j][1]-2*NBFIL:
                LL[i][1][j][2]:=LL[i][1][j][2]-2*NBFIL fi:
        od;
    od;
    n:=nops(c[1])-2:
    b:=[bb]:
    cc:=cross(c,b,n);

    for i from 1 to nops(LL) do
        for j from 1 to nops(LL[i][1]) do
            LL[i][1][j][1]:=numlex(LL[i][1][j][1],cc):
            LL[i][1][j][2]:=numlex(LL[i][1][j][2],cc)
        od;
    od;
    return [LL,cc,[bb]];
end:

transmrelax:=proc(b,n,{showsteps := false})
local mm,X,j,c,L,M,T,ctrivial,B,R,bb,BD,lon,Long,IND,AR,nar;

    ctrivial:=[[],[]]:
    ctrivial[1]:=[[0,0,seq(1,i=1..n-1),0],[seq(0,j=1..n+2)],seq([1,seq(0,j=1..n+1)],i=1..n-1),[seq(0,j=1..n+2)]]:
    ctrivial[2]:=[[0,0,seq(1,i=1..n-1),0],[seq(0,j=1..n+2)],seq([1,seq(0,j=1..n+1)],i=1..n-1),[seq(0,j=1..n+2)]]:
    c := crossings(b,n):
    X := touslesrect(b,n) :
    L := X[1] :mm := X[2] :
    for j from 1 to mm do
        L[j][2] := 1;
    od;
    B:=b:
    BD:=[]:
    Long:=0;
    if showsteps then
        print(le_diagramme_de_tresse_est);
        draw(B,n);
    fi;
    while c<>ctrivial do
        if showsteps then
            print(les_rectangles_sont_maintenant);
            print(tracerect(c,L));
        fi;
        M := neworder(L):
        T := transmission(M,c) :
        if showsteps then
            print(apres_transmission_les_rectangles_sont);
            print(tracerect(c,T));
        fi;
        bb:=[];lon:=1;
        IND:=relaxable(T,c):
        if nops(IND)>=1 then AR:=[arel(IND,T,c,showsteps)] fi:

        while nops(IND)>=1 do

            while AR[2]=1 do
                M := neworder(T):
                T := transmission(M,c):
                if showsteps then
                    print(avant_de_pouvoir_relaxer_une_nouvelle_transmission_est_necessaire):
                    print(tracerect(c,T));
                fi;
                IND:=relaxable(T,c):
                AR:=[arel(IND,T,c,showsteps)]:
            od;

            R:=relaxation(T,AR[1],c):
            if R=A then nar:=nops(AR[1]):
                if nar>1 then
                    AR[1]:=[seq(AR[1][m],m=1..nar-1)]:
                else return ERREUR?
                fi:
            else
                T:=R[1]:
                c:=R[2]:
                IND:=relaxable(T,c):
                B:=[op(B),op(R[3])];
                bb:=[op(bb),op(R[3])];
                BD:=[op(BD),op(R[3])];
                lon:=lon+1:
                if nops(IND)>=1 then
                    if c<>ctrivial then
                        AR:=[arel(IND,T,c,showsteps)]
                    fi:
                fi;
            fi;
        od;
        lon:=ln(lon)/ln(2);
        Long:=Long+lon;
        L:=T:

        if showsteps then
            if nops(bb)>=1 then
                print(on_peut_alors_relaxer_par_la_tresse, bb ,de_longueur,lon);
                print(le_nouveau_diagramme_de_tresse_est_maintenant);
                draw(B,n);
            fi;
        fi;

    od;

    print(la_longueur_totale_de_la_tresse_est,Long,`ie`,evalf(Long));
    print(la_tresse_totale_utilisee_pour_demeler_est,BD);

    return BD;
end:

invers:=proc(b)
local i,m,B;
    m := nops(b);
    B := b;
    for i to m do
        B[i] := -b[m+1-i]
    end do;
    return B;
end:
