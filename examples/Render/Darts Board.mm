unit filter darts (unit image in, int subdivisions: 1-30 (10),
                   float distance: 0-1 (0.2), float width: 0-1 (0.05))
"This inverts the input image in a dart-board like style.  `Width' should not be greater than `distance'."
    ang=2*pi/subdivisions;
    p=in(xy);
    q=if inintv((a-ang/4)%ang,0,ang/2)
        then
            p
        else
            -p+1
        end;
    dist=distance;
    q=if inintv(r%dist,dist-width,dist)
        then
            q
        else
            -q+1
        end;
    rgba:[q[0],q[1],q[2],p[3]]
end
